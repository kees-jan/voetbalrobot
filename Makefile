DOCKER=docker run --rm -v $(PWD):/src -w /src ev3cc sh -c
$(info $(DOCKER))
$(info $(PWD))

all: ev3dev-x64/libev3dev.a googletest-x64/lib/libgmock.a
	$(MAKE) -C mine -k -j8

ev3: ev3dev-arm/libev3dev.a googletest-arm/lib/libgmock.a
	$(DOCKER) "$(MAKE) -C mine -k -j8 CC=arm-linux-gnueabi-gcc CXX=arm-linux-gnueabi-g++ OBJDIR=_obj-arm APPDIR=_bin-arm LIBDIR=_lib-arm"

ev3dev-x64/libev3dev.a :
	mkdir -p ev3dev-x64
	(cd ev3dev-x64 && cmake ../ev3dev-lang-cpp/ -DEV3DEV_PLATFORM=EV3)
	$(MAKE) -C ev3dev-x64 -k -j8

googletest-x64/lib/libgmock.a:
	mkdir -p googletest-x64
	(cd googletest-x64 && cmake ../googletest)
	$(MAKE) -C googletest-x64 -k -j8

ev3dev-arm/libev3dev.a :
	mkdir -p ev3dev-arm
	$(DOCKER) "(cd ev3dev-arm && CC=arm-linux-gnueabi-gcc CXX=arm-linux-gnueabi-g++ cmake ../ev3dev-lang-cpp/ -DEV3DEV_PLATFORM=EV3)"
	$(DOCKER) "$(MAKE) -C ev3dev-arm -k -j8"

googletest-arm/lib/libgmock.a:
	mkdir -p googletest-arm
	$(DOCKER) "(cd googletest-arm && CC=arm-linux-gnueabi-gcc CXX=arm-linux-gnueabi-g++ cmake ../googletest)"
	$(DOCKER) "$(MAKE) -C googletest-arm -k -j8"


clean:
	$(MAKE) -C mine clean
	$(MAKE) -C mine clean OBJDIR=_obj-arm APPDIR=_bin-arm LIBDIR=_lib-arm
	rm -rf googletest-arm googletest-x64 ev3dev-arm ev3devx64

dummy:
	true

docker:
	docker pull ev3dev/debian-stretch-cross
	docker tag ev3dev/debian-stretch-cross ev3cc


.PHONY: all ev3 clean dummy
