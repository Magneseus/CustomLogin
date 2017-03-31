custom_login: custom_login.c
	gcc -fPIC -c custom_login.c
	gcc -shared -o custom_login.so custom_login.o -lpam

install: custom_login.so
	cp custom_login.so /lib/security/

uninstall:
	rm -f /lib/security/custom_login.so

clean:
	rm -f *.o custom_login
