MIX = mix
CFLAGS = -g -O3 -ansi -pedantic -Wall -Wextra -Wno-unused-parameter

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)

YAML_PATH = deps/yaml

CFLAGS += -I$(YAML_PATH)/include

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC

	ifeq ($(shell uname),Darwin)
		LDFLAGS += -dynamiclib -undefined dynamic_lookup
	endif
endif

.PHONY: all yomel clean

all: yomel

yomel:
	$(MIX) compile

$(YAML_PATH)/src/.libs/libyaml.a:
	cd $(YAML_PATH) && ./bootstrap && ./configure
	$(MAKE) -C $(YAML_PATH)/src

priv/yomel.so: priv $(YAML_PATH)/src/.libs/libyaml.a c_src/yomel_nif.c
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ c_src/*.c $(YAML_PATH)/src/.libs/libyaml.a

priv:
	mkdir priv

clean:
	$(MIX) clean
	$(MAKE) -C $(YAML_PATH) clean
	rm -r priv/*
