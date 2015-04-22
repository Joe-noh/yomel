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

static ERL_NIF_TERM yomel_initialize(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    yomel_libyaml* yaml = enif_alloc_resource(yomel_libyaml_type, sizeof(yomel_libyaml));

    yaml_parser_initialize(&yaml->parser);
    return enif_make_resource(env, yaml);
}

static ERL_NIF_TERM yomel_input_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    yomel_libyaml* yaml;
    enif_get_resource(env, argv[0], yomel_libyaml_type, (void**)&yaml);

    ErlNifBinary bin;
    enif_inspect_binary(env, argv[1], &bin);

    yaml_parser_set_input_string(&yaml->parser, bin.data, bin.size);

    return enif_make_resource(env, yaml);
}

static ERL_NIF_TERM yomel_next_event(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    yomel_libyaml* yaml;
    enif_get_resource(env, argv[0], yomel_libyaml_type, (void**)&yaml);

    if (!yaml_parser_parse(&yaml->parser, &yaml->event)) {
        return utils_get_atom(env, "halt");
    }

    return handle_event(env, &yaml->event);
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
        utils_nullable_chars_to_binary(env, tag),
        utils_nullable_chars_to_binary(env, anchor),
        utils_scalar_style_to_atom(env, event->data.scalar.style)
    );
}

static int on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
    yomel_libyaml_type = enif_open_resource_type(
        env, "Elixir.Yomel.Parser", "yomel_libyaml_type",
        yomel_libyaml_destructor, ERL_NIF_RT_CREATE, NULL
    );

    return 0;
}

static ErlNifFunc nif_functions[] = {
    {"initialize", 0, yomel_initialize},
    {"input_string", 2, yomel_input_string},
    {"next_event", 1, yomel_next_event}
};

ERL_NIF_INIT(Elixir.Yomel.Parser, nif_functions, on_load, 0, 0, NULL);

