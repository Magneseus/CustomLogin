# Custom Login
COMP 3000 Term Project

Matt Mayer (100969802)
Kyle Causton (100947775)
Edward Ye (100972832)

## Building:

This will add custom_login.so to /lib/security/

~~~~
make

sudo make install

~~~~

## Testing it out


### Custom Login instructions:

Put this at the top of /etc/pam.d/su

~~~~
auth		sufficient	custom_login.so
account		sufficient	custom_login.so
session		sufficient	custom_login.so
~~~~

Type:

~~~
su
~~~

Then input the mouse sequence : left, left, right. 

Hit ENTER.

### Mouse gesture login instructions:

~~~
auth		sufficient	mouse_gesture_login.so
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



