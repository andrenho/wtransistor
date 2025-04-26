#
# setup
#

PROJECT_NAME = libwengine
PROJECT_VERSION = 0.0.1

all: libwengine.a

include mk/config.mk

#
# object files
#

OBJ = \
	engine/wengine.o \
	luaw/luaw.o

#
# dependencies
#

LUAJIT_PATH = $(CONFIG_MK_DIR)LuaJIT
RAYLIB_PATH = $(CONFIG_MK_DIR)raylib
CPPFLAGS += -I$(LUAJIT_PATH)/src

libluajit.a:
	mkdir -p $(LUAJIT_PATH)
	git clone --depth=1 https://github.com/LuaJIT/LuaJIT.git $(LUAJIT_PATH) || true
	rm -rf !$/.git
	$(MAKE) -C $(LUAJIT_PATH)/src MACOSX_DEPLOYMENT_TARGET=$(MACOS_VERSION) libluajit.a
	cp $(LUAJIT_PATH)/src/libluajit.a .

libraylib.a:
	mkdir -p $(RAYLIB_PATH)
	git clone --depth=1 https://github.com/raysan5/raylib.git $(RAYLIB_PATH) || true
	rm -rf !$/.git
	$(MAKE) -C $(RAYLIB_PATH)/src MACOSX_DEPLOYMENT_TARGET=$(MACOS_VERSION)
	cp $(RAYLIB_PATH)/src/libraylib.a .
#
# libraries
#

libwengine-part.a: $(OBJ)
	ar rcs $@ $^

libwengine.a: libwengine-part.a libluajit.a libraylib.a
ifdef APPLE
	libtool -static -o $@ $^
else
	libtool --mode=link cc -static -o $@ $^
endif

#
# other
#

clean:
	rm -f libwengine.a libwengine-part.a $(OBJ)

distclean:
	rm -rf mk/LuaJIT mk/raylib
	rm -f libluajit.a libraylib.a: