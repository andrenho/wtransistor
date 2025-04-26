#
# setup
#

PROJECT_NAME = transistor
PROJECT_VERSION = 0.0.6

all: $(PROJECT_NAME)

include contrib/libwengine/mk/config.mk

LDFLAGS += -lpthread

#
# object files
#

OBJ = main.o

#
# executable
#

$(PROJECT_NAME): $(OBJ)
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
	# $(MAKE) -C contrib/libwengine clean
	rm -rf build-sdl3 libSDL3.a libluajit.a libwengine.a

FORCE: ;
