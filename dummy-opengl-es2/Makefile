#!/usr/bin/make -f

%.o: %.c
	$(HOST_TUPLE)-gcc -fPIC -DPIC -c -o $@ $<

all: libEGL.so.1.7.5.0 libGLESv2.so.1.7.5.0

install: all
	rm -rf $(DESTDIR)/usr/lib/libEGL.so.1.7.5.0 $(DESTDIR)/usr/lib/libGLESv2.so.1.7.5.0
	rm -rf $(DESTDIR)/usr/lib/libEGL.so.1 $(DESTDIR)/usr/lib/libGLESv2.so.2
	rm -rf $(DESTDIR)/usr/lib/libEGL.so $(DESTDIR)/usr/lib/libGLESv2.so
	cp libEGL.so.1.7.5.0 $(DESTDIR)/usr/lib/libEGL.so.1.7.5.0
	cp libGLESv2.so.1.7.5.0 $(DESTDIR)/usr/lib/libGLESv2.so.1.7.5.0
	ln -s libEGL.so.1.7.5.0 $(DESTDIR)/usr/lib/libEGL.so.1
	ln -s libGLESv2.so.1.7.5.0 $(DESTDIR)/usr/lib/libGLESv2.so.2
	ln -s libEGL.so.1 $(DESTDIR)/usr/lib/libEGL.so
	ln -s libGLESv2.so.2 $(DESTDIR)/usr/lib/libGLESv2.so
	rm -rf $(DESTDIR)/usr/include/KHR $(DESTDIR)/usr/include/EGL $(DESTDIR)/usr/include/GLES2
	cp -a include/KHR include/EGL include/GLES2 $(DESTDIR)/usr/include

libEGL.so.1.7.5.0: libEGL.o
	$(HOST_TUPLE)-gcc -shared -Wl,-soname,libEGL.so.1 -o $@ $<

libGLESv2.so.1.7.5.0: libGLESv2.o
	$(HOST_TUPLE)-gcc -shared -Wl,-soname,libGLESv2.so.2 -o $@ $<

clean:
	rm -f *.o *.so*
