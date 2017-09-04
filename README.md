# Custom Login

- Matt Mayer
- Kyle Causton
- Edward Ye

![](https://i.gyazo.com/d3bf892dfd70f34fdd7eaca10e047b02.gif)

Please use the "login_config.sh" script to install and uninstall any login modules.
You will need to run it as sudo in order for them to install properly. The default behaviour of
the script is to modify the authentication scheme of "su". This is easily modified by setting 
the variable in the "login_config.sh" file called LOGIN_TYPE to "login" instead of "su".

"su" is a much easier program to test however, as you do not need to log in and out each time.



# GENERAL INSTRUCTIONS

Help: #> ./login_config.sh -h

Blank Template: #> ./login_config.sh -b




To make and install any of the logins we've provided, run the login_config.sh
script, with the login type you desire.

~~~
eg:

    #> sudo ./login_config.sh -i custom_login
 OR
    #> sudo ./login_config.sh -i mouse_gesture_login
~~~

To remove the custom login and replace it with the default login behaviour:

~~~
    #> sudo ./login_config.sh -r
~~~

To add your own version:

~~~
    #> ./login_config.sh -a /PATH/TO/YOUR_C_FILE_HERE.c
    #> 
    #> sudo ./login_config.sh -i YOUR_C_FILE_HERE.c
       OR
    #> sudo ./login_config.sh -i YOUR_C_FILE_HERE
~~~




## Testing it out

### Custom Login instructions:

Put this at the top of /etc/pam.d/su

~~~~
./login_config.sh -i custom_login
~~~~

Type:

~~~
su
~~~

Then input the mouse sequence : left, left, right. 

Hit ENTER.

### Mouse gesture login instructions:

~~~
./login_config.sh -i mouse_gesture_login
~~~

The password is UP, LEFT, DOWN, RIGHT.

Uses relative mouse movement. Must move at least 50 pixel in the
direction you want to go and the change in the direction you want to
go must be the largest change in the mouse (if you want to move UP,
your mouse might move a bit to the RIGHT or LEFT, but UP must move
the furthest).

#### Entering the password:

1. Click once on the mouse, to start.

2. Move the mouse UP.

3. Move the mouse LEFT.
 
4. Move mouse DOWN. 
 
5. Move the mouse RIGHT.

6. Hit ENTER.


### Keyboard time login instructions:

~~~
./login_config.sh -i keyboard_time_login
~~~

The password is a sequence of four 2 second delays between keypresses.

#### Entering the password:

1. Press any key on the keyboard (other than ENTER).

2. Wait 2 or more seconds.

3. Do 1

4. Do 2

5. Do 1

6. Do 2

7. Do 1

8. Do 2

9. ENTER.

### Hangman login instructions:

~~~
./login_config.sh -i hangman_login
~~~

The possible words are: apple, banana, grape, lemon, orange. There
are 6 wrong letter guess.

#### Entering the password:

Use the keyboard. Guess letters in the word. If you get 6 wrong
guesses the login fails.
