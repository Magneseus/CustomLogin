# Custom Login
COMP 3000 Term Project

Matt Mayer (100969802)
Kyle Causton (100947775)
Edward Ye (100972832)


# GENERAL INSTRUCTIONS

To make and install any of the logins we've provided, run the login_config.sh
script, with the login type you desire.

eg: #> ./login_config.sh -i custom_login
 OR
    #> ./login_config.sh -i mouse_gesture_login


To remove the custom login and replace it with the default login behaviour:
    #> ./login_config.sh -r


To add your own version:
    #> ./login_config.sh -a /PATH/TO/YOUR_C_FILE_HERE.c
    #> 
    #> ./login_config.sh -i YOUR_C_FILE_HERE.c
       OR
    #> ./login_config.sh -i YOUR_C_FILE_HERE




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
direction you want to go. Right mouse click parses the change in the
Y value, left mouse click parses the change in the X value.

#### Entering the password:

1. Click once on the mouse, to start.

2. Move the mouse UP. Click the right mouse button to get the change in
the Y position.

3. Move the mouse LEFT. Click the left mouse button to get the change
in the X position. 
 
4. Move mouse DOWN. Click right mouse button. 
 
5. Move the mouse RIGHT. Click left mouse button.

6. Hit ENTER.



