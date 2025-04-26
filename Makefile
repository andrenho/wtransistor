#
# setup
#

PROJECT_NAME = transistor
PROJECT_VERSION = 0.0.6

all: $(PROJECT_NAME)

include contrib/libwengine/mk/config.mk

LIB_DEPS = libwengine.a

CPPFLAGS += -Icontrib/libwengine -Icontrib/libwengine/mk/LuaJIT/src
LDFLAGS += -lpthread

#
# object files
#

OBJ = main.o

#
# dependencies
#

libwengine.a:
	$(MAKE) -C contrib/libwengine
	cp contrib/libwengine/libwengine.a .

#
# executable
#

$(PROJECT_NAME): $(OBJ) $(LIB_DEPS)
	$(CXX) -o $@ $^ $(LDFLAGS)
ifdef RELEASE
	strip $@
endif

release:
	make RELEASE=1

#
# cleanup
#

.PHONY: softclean
softclean:
	rm -f $(PROJECT_NAME) $(OBJ) $(CONTRIB_OBJ) $(CLEANFILES) $(RESOURCES:=.h) $(EMBEDDED_HH) $(ENGINE_SRC_LUA:=.h) *.d **/*.d

.PHONY: clean
clean: softclean
	$(MAKE) -C contrib/libwengine clean
	rm -rf libwengine.a

distclean:
	$(MAKE) -C contrib/libwengine distclean

FORCE: ;
