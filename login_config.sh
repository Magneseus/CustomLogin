#!/bin/bash

# Change this to whatever you want to edit the config for
# su,
# login,
# etc.
LOGIN_TYPE="su"

func_help()
{
	echo "login_config - configuration of PAM modules and their corresponding config files"
	echo " "
	echo "login_config [options] [arguments]"
	echo " "
	echo "options:"
	echo "-h, --help			prints this menu"
	echo "-a, --add 	[*.c file]	add a *.c file to the possible login modules"
	echo "-i, --install	[module name]	install a module to /lib/security"
	echo "-s, --set 	[module name]	set a module as the defauly login type"
	echo "-r, --reset			reset the login type to the default prompt"
	echo "-b, --blank 			creates a blank PAM module in a .c file for user modification"
}

# Print help if no arguments given
if [ $# -eq 0 ]; then
	func_help
fi


# DEFINE FUNCTIONS BELOW

# Adds a *.c file to the ./src directory
func_add()
{
	# Check if we have the proper number of arguments
	if [ $# -lt 2 ]; then
		echo "Please enter the path to your *.c file."
		exit 0
	fi
	
	# Make src directory if it doesn't already exist
	if [ ! -d "./src" ]; then
		printf "Making the src/ dir..."
		mkdir "src"
		printf "done.\n"
	fi
	
	printf "Copying your file ($2) to the src directory..."
	# Copy the file to our ./src directory
	cp "$2" "./src/$2"
	printf "done.\n"
}

# Makes the file and installs it to the /lib/security directory
# Configures the files
func_install()
{
	# Check that we're being run by root
	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root/sudo."
		exit 0
	fi
	
	# Check if we have the proper number of arguments
	if [ $# -lt 2 ]; then
		echo "Please enter your selected module."
		exit 0
	fi
	
	# Strip the .c from the file name
	MODULE=`echo "$2" | cut -d'.' -f1`
	
	# Make bin directory if it doesn't already exist
	if [ ! -d "./bin" ]; then
		printf "Making the bin/ dir..."
		mkdir "bin"
		printf "done.\n"
	fi
	
	# Get the current login module
	if [ -f "./.login_module" ]; then
		curModule=$(<./.login_module)
	fi
	
	# If the curModule exists, then remove the module and the reset the config
	if [ ! -z "$curModule" ]; then
		printf "Uninstalling previous module: %s ..." "$curModule"
		func_reset
		printf "done.\n"
	fi
	
	# Change to the src directory
	cd "src"
	
	printf "Compiling the %s module..." "$MODULE"
	
	# Make the file
	make -s targetModule="$MODULE"
	
	# Install the file
	make -s install targetModule="$MODULE"
	
	printf "done.\n"
	printf "Copying %s.so to the /lib/security directory..." "$MODULE"
	
	# Copy the binary to the bin directory
	cp "$MODULE.so" "../bin/$MODULE.so"
	
	printf "done.\n"
	printf "Cleaning the bin/ directory..."
	
	# Clean the source directory
	make -s clean
	
	printf "done.\n"
	
	# Change back to original directory
	cd "../"
	
	# Set the config files
	func_set "$@"
}

# Sets up the proper config files
func_set()
{
	# Check that we're being run by root
	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root/sudo."
		exit 0
	fi

	# Check if we have the proper number of arguments
	if [ $# -lt 2 ]; then
		echo "Please enter your selected module."
		exit 0
	fi
	
	# Strip the .c from the file name
	MODULE=`echo "$2" | cut -d'.' -f1`
	
	# Check that the module has been built
	if [ ! -f "/lib/security/$MODULE.so" ]; then
		echo "Your module has not been installed correctly. Please try --install again."
		exit 0
	fi
	
	# Set the current module file
	echo "$MODULE" > "./.login_module"
	
	# If we haven't backed up the login config already, then do so
	if [ ! -f "./.~login" ]; then
		# Backup the current login config
		printf "Backing up your current default PAM config (%s) ..." "$LOGIN_TYPE"
		cp "/etc/pam.d/$LOGIN_TYPE" "./.~login"
		printf "done.\n"
	else
		# If we have already backed up the config then revert it
		cp "./.~login" "/etc/pam.d/$LOGIN_TYPE"
	fi
	
	printf "Modifying the PAM config (%s) ..." "$LOGIN_TYPE"
	
	# Add the required line to the beginning of the login config file
	echo -e "auth		sufficient	$MODULE.so\naccount		sufficient	$MODULE.so\nsession		sufficient	$MODULE.so" | cat - "/etc/pam.d/$LOGIN_TYPE" > temp && mv temp "/etc/pam.d/$LOGIN_TYPE"
	
	printf "done.\n"
	
}

# Resets the login process to the default
func_reset()
{
	# Check that we're being run by root
	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root/sudo."
		exit 0
	fi
	
	# If no modules is installed, just return
	if [ ! -f "./.login_module" ]; then
		echo "No module installed right now."
		exit 0
	fi
	
	# Get the current module
	curModule=$(<./.login_module)
	
	printf "Restoring your default PAM config (%s) ..." "$LOGIN_TYPE"
	
	# Delete the login module file
	rm "./.login_module"
	
	# Remove the current config file
	rm "/etc/pam.d/$LOGIN_TYPE"
	
	# Revert the config file
	cp -f "./.~login" "/etc/pam.d/$LOGIN_TYPE"
	
	# Remove the current backup of the config file
	rm "./.~login"
	
	# Change to the src directory
	cd "./src"
	
	printf "done.\n"
	printf "Uninstalling the %s module..." "$curModule"
	
	# Removes the module
	make -s uninstall targetModule="$curModule"
	
	printf "done.\n"
	
	# Changes to regular directory
	cd "../"
}

# Creates a blank *.c file for the user to base their password module off of
func_blank()
{
	# Check that the file we want to copy from exists
	if [ ! -f "./src/.blank" ]; then
		echo "Original copy not present in /src directory. Please retain another copy from the original package."
	fi

	# Check that the blank file doesn't exist already
	if [ ! -f "./blankPAM.c" ]; then
		cp "./src/.blank" "./blankPAM.c"
		printf "New blank file created: ./blankPAM.c\n"
	else
		echo "Blank file is already present, please remove or reaname the file."
	fi
}


# Parse arguments
if [ $# -gt 0 ]; then
	case "$1" in
		-h|--help)
			func_help
			;;
		-a|--add)
			func_add "$@"
			;;
		-i|--install)
			func_install "$@"
			;;
		-s|--set)
			func_set "$@"
			;;
		-r|--reset)
			func_reset
			;;
		-b|--blank)
			func_blank
			;;
	esac
fi

exit 0
