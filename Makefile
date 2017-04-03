all: custom_login.c mouse_gesture_login.c
	gcc -fPIC -c custom_login.c
	gcc -shared -o custom_login.so custom_login.o -lpam
	gcc -fPIC -c mouse_gesture_login.c
	gcc -shared -o mouse_gesture_login.so mouse_gesture_login.o -lpam

install: custom_login.so mouse_gesture_login.so
	cp -f custom_login.so /lib/security/
	cp -f mouse_gesture_login.so /lib/security/

uninstall:
	rm -f /lib/security/custom_login.so
	rm -f /lib/security/mouse_gesture_login.so

clean:
	rm -f *.o *.so
