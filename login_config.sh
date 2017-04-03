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
		mkdir "src"
	fi
	
	# Copy the file to our ./src directory
	cp "$2" "./src/$2"
}

# Makes the file and installs it to the /lib/security directory
# Configures the files
func_install()
{
	# Check if we have the proper number of arguments
	if [ $# -lt 2 ]; then
		echo "Please enter your selected module."
		exit 0
	fi
	
	# Strip the .c from the file name
	MODULE=`echo "$2" | cut -d'.' -f1`
	
	# Make bin directory if it doesn't already exist
	if [ ! -d "./bin" ]; then
		mkdir "bin"
	fi
	
	# Get the current login module
	if [ -f "./.login_module" ]; then
		curModule=$(<./.login_module)
	fi
	
	# If the curModule exists, then remove the module and the reset the config
	if [ ! -z "$curModule"]; then
		func_reset
	fi
	
	# Change to the src directory
	cd "src"
	
	# Make the file
	make targetModule="$MODULE"
	
	# Install the file
	make install targetModule="$MODULE"
	
	# Copy the binary to the bin directory
	cp "$MODULE.so" "../bin/$MODULE.so"
	
	# Clean the source directory
	make clean
	
	# Change back to original directory
	cd "../"
	
	# Set the config files
	func_set "$@"
}

# Sets up the proper config files
func_set()
{
	# Check if we have the proper number of arguments
	if [ $# -lt 2 ]; then
		echo "Please enter your selected module."
		exit 0
	fi
	
	# Strip the .c from the file name
	MODULE=`echo "$2" | cut -d'.' -f1`
	
	# Check that the module has been built
	if [ ! -f "/lib/security/$MODULE.so" ]; then
		echo "Your module has not been installed correctly."
		exit 0
	fi
	
	# Set the current module file
	echo "$MODULE" > "./.login_module"
	
	# If we haven't backed up the login config already, then do so
	if [ ! -f "./.~login" ]; then
		# Backup the current login config
		cp "/etc/pam.d/$LOGIN_TYPE" "./.~login"
	else
		# If we have already backed up the config then revert it
		cp "./.~login" "/etc/pam.d/$LOGIN_TYPE"
	fi
	
	# Add the required line to the beginning of the login config file
	echo -e "auth		sufficient	$MODULE.so\naccount		sufficient	$MODULE.so\nsession		sufficient	$MODULE.so" | cat - "/etc/pam.d/$LOGIN_TYPE" > temp && mv temp "/etc/pam.d/$LOGIN_TYPE"
	
}

# Resets the login process to the default
func_reset()
{
	# If no modules is installed, just return
	if [ ! -f "./.login_module" ]; then
		echo "No module installed right now."
		exit 0
	fi
	
	# Get the current module
	curModule=$(<./.login_module)
	
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
	
	# Removes the module
	make uninstall targetModule="$curModule"
	
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
