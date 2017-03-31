custom_login: custom_login.c
	gcc -fPIC -c custom_login.c
	gcc -shared -o custom_login.so custom_login.o -lpam

clean:
	rm -f *.o custom_login
