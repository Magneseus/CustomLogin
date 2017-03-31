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
