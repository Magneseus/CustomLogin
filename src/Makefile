targetModule = "custom_login"

all:
	gcc -fPIC -c $(targetModule).c
	gcc -shared -o $(targetModule).so $(targetModule).o -lpam

install: 
	cp -f $(targetModule).so /lib/security/$(targetModule).so

uninstall:
	rm -f /lib/security/$(targetModule).so

clean:
	rm -f *.o *.so
