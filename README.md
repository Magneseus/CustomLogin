# Custom Login
COMP 3000 Term Project

Matt Mayer (100969802)
Kyle Causton (100947775)
Edward Ye (100972832)


# GENERAL INSTRUCTIONS

To make and install any of the logins we've provided, run the login_config.sh
script, with the login type you desire.

~~~
eg:

    #> ./login_config.sh -i custom_login
 OR
    #> ./login_config.sh -i mouse_gesture_login
~~~

To remove the custom login and replace it with the default login behaviour:

~~~
    #> ./login_config.sh -r
~~~

To add your own version:

~~~
    #> ./login_config.sh -a /PATH/TO/YOUR_C_FILE_HERE.c
    #> 
    #> ./login_config.sh -i YOUR_C_FILE_HERE.c
       OR
    #> ./login_config.sh -i YOUR_C_FILE_HERE
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



