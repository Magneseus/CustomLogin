all: custom_login.c mouse_gesture_login.c
	gcc -fPIC -c custom_login.c mouse_gesture_login.c keyboard_time_login.c
	gcc -shared -o custom_login.so custom_login.o -lpam
	gcc -shared -o mouse_gesture_login.so mouse_gesture_login.o -lpam
	gcc -shared -o keyboard_time_login.so keyboard_time_login.o -lpam

install: custom_login.so mouse_gesture_login.so keyboard_time_login.so
	cp -f custom_login.so /lib/security/
	cp -f mouse_gesture_login.so /lib/security/
	cp -f keyboard_time_login.so /lib/security/

uninstall:
	rm -f /lib/security/custom_login.so /lib/security/mouse_gesture_login.so /lib/security/keyboard_time_login.so

clean:
	rm -f *.o *.so
