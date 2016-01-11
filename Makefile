MIX = mix
CFLAGS += -g -O3 -ansi -pedantic -Wall -Wextra -Wno-unused-parameter

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC

	ifeq ($(shell uname),Darwin)
		LDFLAGS += -dynamiclib -undefined dynamic_lookup -lyaml
	endif
endif

.PHONY: all yomel clean

all: yomel

yomel:
	$(MIX) compile

priv/yomel.so: priv c_src/yomel_nif.c
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ c_src/*.c

priv:
	mkdir priv

clean:
	$(MIX) clean
	rm -r priv/*
