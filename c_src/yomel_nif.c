#include <erl_nif.h>
#include <yaml.h>
#include <string.h>

#include "utils.h"

typedef struct {
    yaml_parser_t parser;
    yaml_event_t  event;
} yomel_libyaml;

static ERL_NIF_TERM handle_event(ErlNifEnv*, yaml_event_t*);

static ERL_NIF_TERM handle_stream_start_event(  ErlNifEnv*, yaml_event_t*);
static ERL_NIF_TERM handle_stream_end_event(    ErlNifEnv*, yaml_event_t*);
static ERL_NIF_TERM handle_document_start_event(ErlNifEnv*, yaml_event_t*);
static ERL_NIF_TERM handle_document_end_event(  ErlNifEnv*, yaml_event_t*);
static ERL_NIF_TERM handle_sequence_start_event(ErlNifEnv*, yaml_event_t*);
static ERL_NIF_TERM handle_sequence_end_event(  ErlNifEnv*, yaml_event_t*);
static ERL_NIF_TERM handle_mapping_start_event( ErlNifEnv*, yaml_event_t*);
static ERL_NIF_TERM handle_mapping_end_event(   ErlNifEnv*, yaml_event_t*);
static ERL_NIF_TERM handle_alias_event(         ErlNifEnv*, yaml_event_t*);
static ERL_NIF_TERM handle_scalar_event(        ErlNifEnv*, yaml_event_t*);

static ErlNifResourceType* yomel_libyaml_type = NULL;

static void yomel_libyaml_destructor(ErlNifEnv* env, void* obj) {
    yomel_libyaml* yaml = (yomel_libyaml *)obj;

    yaml_parser_delete(&yaml->parser);
    yaml_event_delete(&yaml->event);
}

static ERL_NIF_TERM yomel_parse_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    yaml_parser_t parser;
    yaml_event_t event;
    yaml_parser_initialize(&parser);

    ErlNifBinary bin;
    enif_inspect_binary(env, argv[0], &bin);

    yaml_parser_set_input_string(&parser, bin.data, bin.size);

    int go_on_parsing = 1;
    ERL_NIF_TERM list = enif_make_list(env, 0);
    do {
        if (!yaml_parser_parse(&parser, &event)) {
            return list;
        }
        list = enif_make_list_cell(env, handle_event(env, &event), list);

        if (event.type == YAML_STREAM_END_EVENT) {
            go_on_parsing = 0;
        }
        yaml_event_delete(&event);
    } while(go_on_parsing);

    yaml_parser_delete(&parser);

    return list;
}

static ERL_NIF_TERM handle_event(ErlNifEnv* env, yaml_event_t* event) {
    switch (event->type) {
    case YAML_STREAM_START_EVENT:
        return handle_stream_start_event(env, event);
    case YAML_STREAM_END_EVENT:
        return handle_stream_end_event(env, event);
    case YAML_DOCUMENT_START_EVENT:
        return handle_document_start_event(env, event);
    case YAML_DOCUMENT_END_EVENT:
        return handle_document_end_event(env, event);
    case YAML_SEQUENCE_START_EVENT:
        return handle_sequence_start_event(env, event);
    case YAML_SEQUENCE_END_EVENT:
        return handle_sequence_end_event(env, event);
    case YAML_MAPPING_START_EVENT:
        return handle_mapping_start_event(env, event);
    case YAML_MAPPING_END_EVENT:
        return handle_mapping_end_event(env, event);
    case YAML_ALIAS_EVENT:
        return handle_alias_event(env, event);
    case YAML_SCALAR_EVENT:
        return handle_scalar_event(env, event);
    default:
        return utils_get_atom(env, "halt");
    }
}

static ERL_NIF_TERM handle_stream_start_event(ErlNifEnv* env, yaml_event_t* event) {
    return utils_get_atom(env, "stream_start");
}

static ERL_NIF_TERM handle_stream_end_event(ErlNifEnv* env, yaml_event_t* event) {
    return utils_get_atom(env, "stream_end");
}

static ERL_NIF_TERM handle_document_start_event(ErlNifEnv* env, yaml_event_t* event) {
    return utils_get_atom(env, "document_start");
}

static ERL_NIF_TERM handle_document_end_event(ErlNifEnv* env, yaml_event_t* event) {
    return utils_get_atom(env, "document_end");
}

static ERL_NIF_TERM handle_sequence_start_event(ErlNifEnv* env, yaml_event_t* event) {
    unsigned char* anchor       = event->data.sequence_start.anchor;
    unsigned char* tag          = event->data.sequence_start.tag;
    yaml_sequence_style_t style = event->data.sequence_start.style;

    return enif_make_tuple4(
        env,
        utils_get_atom(env, "sequence_start"),
        utils_nullable_chars_to_binary(env, anchor),
        utils_nullable_chars_to_binary(env, tag),
        utils_sequence_style_to_atom(env, style)
    );
}

static ERL_NIF_TERM handle_sequence_end_event(ErlNifEnv* env, yaml_event_t* event) {
    return utils_get_atom(env, "sequence_end");
}

static ERL_NIF_TERM handle_mapping_start_event(ErlNifEnv* env, yaml_event_t* event) {
    unsigned char* anchor      = event->data.mapping_start.anchor;
    unsigned char* tag         = event->data.mapping_start.tag;
    yaml_mapping_style_t style = event->data.mapping_start.style;

    return enif_make_tuple4(
        env,
        utils_get_atom(env, "mapping_start"),
        utils_nullable_chars_to_binary(env, anchor),
        utils_nullable_chars_to_binary(env, tag),
        utils_mapping_style_to_atom(env, style)
    );
}

static ERL_NIF_TERM handle_mapping_end_event(ErlNifEnv* env, yaml_event_t* event) {
    return utils_get_atom(env, "mapping_end");
}

static ERL_NIF_TERM handle_alias_event(ErlNifEnv* env, yaml_event_t* event) {
    unsigned char* anchor = event->data.alias.anchor;

    return enif_make_tuple2(
        env,
        utils_get_atom(env, "alias"),
        utils_nullable_chars_to_binary(env, anchor)
    );
}

static ERL_NIF_TERM handle_scalar_event(ErlNifEnv* env, yaml_event_t* event) {
    unsigned char* anchor = event->data.scalar.anchor;
    unsigned char* tag    = event->data.scalar.tag;
    unsigned char* value  = event->data.scalar.value;
    int length = event->data.scalar.length;

    return enif_make_tuple5(
        env,
        utils_get_atom(env, "scalar"),
        utils_chars_to_binary(env, value, length),
        utils_nullable_chars_to_binary(env, anchor),
        utils_nullable_chars_to_binary(env, tag),
        utils_scalar_style_to_atom(env, event->data.scalar.style)
    );
}

static ErlNifFunc nif_functions[] = {
    {"nif_parse_string", 1, yomel_parse_string}
};

ERL_NIF_INIT(Elixir.Yomel.Parser, nif_functions, 0, 0, 0, NULL);

