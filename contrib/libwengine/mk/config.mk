# Variables that can be set:
#   RELEASE=1        create a release build
#   PROJECT_NAME
#   PROJECT_VERSION

#
# compiler configuration
#

CFLAGS += -D_GNU_SOURCE
CPPFLAGS += -MMD -MP   # generate dependencies
CXXFLAGS += -std=c++20 -I.
LDFLAGS += -lm

ifdef RELEASE
	CPPFLAGS += -Ofast -flto -fdata-sections -ffunction-sections -flto -DNDEBUG -DRELEASE
	ifeq ($(CXX),g++)
		LDFLAGS += -flto -Wl,--gc-sections
	else
		LDFLAGS += -flto -Wl,-dead_strip
	endif
else
	CPPFLAGS += -ggdb -O0 -DDEV
	WARNINGS := -Wall -Wextra -Wformat-nonliteral -Wshadow -Wwrite-strings -Wmissing-format-attribute -Wswitch-enum -Wmissing-noreturn
	ifeq ($(CXX),g++)
		WARNINGS += -Wsuggest-attribute=pure -Wsuggest-attribute=const -Wsuggest-attribute=noreturn -Wsuggest-attribute=malloc -Wsuggest-attribute=format -Wsuggest-attribute=cold
	endif
	WARNINGS += -Wno-unused-parameter -Wno-unused -Wno-unknown-warning-option -Wno-sign-compare  # ignore these warnings
endif

CPPFLAGS += -DPROJECT_VERSION=\"$(PROJECT_VERSION)\"

#
# generate embedded files (require LuaJIT)
#

CONFIG_MK_DIR:= $(dir $(lastword $(MAKEFILE_LIST)))
GENHEADER := $(CONFIG_MK_DIR)/genheader.lua

%.png.h: %.png; $(GENHEADER) $^ > $@
%.jpg.h: %.jpg; $(GENHEADER) $^ > $@
%.wav.h: %.wav; $(GENHEADER) $^ > $@
%.mod.h: %.mod; $(GENHEADER) $^ > $@
%.ttf.h: %.ttf; $(GENHEADER) $^ > $@
%.txt.h: %.txt; $(GENHEADER) $^ > $@
%.bin.h: %.bin; $(GENHEADER) $^ > $@

%.lua.h: %.lua
ifdef RELEASE
	$(GENHEADER) $^ > $@ lua-strip
else
	$(GENHEADER) $^ > $@ lua
endif

.DELETE_ON_ERROR=%.h

#
# generate rule dependencies
#

DEPENDS = $(shell find . -type f -name '*.d')
-include $(DEPENDS)

#
# leak check command
#

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)  # Apple
	APPLE := 1
	LEAKS_CMD := MallocStackLogging=1 leaks --atExit --
	MACOS_VERSION := $(shell cut -d '.' -f 1,2 <<< $$(sw_vers -productVersion))
	CFLAGS += -std=c2x
	CPPFLAGS += -mmacosx-version-min=$(MACOS_VERSION)
	export MACOSX_DEPLOYMENT_TARGET=$(MACOS_VERSION)
else
	CFLAGS += -std=c23
	LEAKS_CMD := valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --fair-sched=yes
	LEAKS_SUPP := --suppressions=valgrind.supp
endif

#
# special rules
#

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(WARNINGS) -c -o $@ $<

%.o: %.cc
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(WARNINGS) -c -o $@ $<

#
# leaks
#

ifdef PROJECT_NAME

leaks: $(PROJECT_NAME)
	$(LEAKS_CMD) $(LEAKS_SUPP) ./$^

helgrind: $(PROJECT_NAME)
	valgrind --tool=helgrind --fair-sched=yes ./$^

drd: $(PROJECT_NAME)
	valgrind --tool=drd --fair-sched=yes ./$^

endif

#
# special rules
#

.PHONY: config
config:
	@echo ===============================
	@echo CC            = $(CC)
	@echo CXX           = $(CXX)
	@echo CFLAGS        = $(CFLAGS)
	@echo CPPFLAGS      = $(CPPFLAGS)
	@echo CXXFLAGS      = $(CXXFLAGS)
	@echo LDFLAGS       = $(LDFLAGS)
	@echo DEPENDS       = $(DEPENDS)
	@echo CONFIG_MK_DIR = $(CONFIG_MK_DIR)
	@echo ===============================

deepclean:
	git clean -fdx

update:
	git submodule update --init --remote --merge --recursive

compile_commands: clean
	bear -- $(MAKE)