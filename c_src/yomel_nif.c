#include <erl_nif.h>
#include <yaml.h>

typedef struct {
    yaml_parser_t parser;
    yaml_event_t  event;
} yomel_libyaml;

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
    unsigned char* input = bin.data;
    size_t length = bin.size;

    yaml_parser_set_input_string(&yaml->parser, input, length);

    return enif_make_resource(env, yaml);
}

static ERL_NIF_TERM yomel_next_event(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    yomel_libyaml* yaml;
    enif_get_resource(env, argv[0], yomel_libyaml_type, (void**)&yaml);

    yaml_parser_parse(&yaml->parser, &yaml->event);

    return enif_make_resource(env, yaml);
}

static ERL_NIF_TERM yomel_parse_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    yaml_parser_t parser;
    yaml_event_t event;

    if (!yaml_parser_initialize(&parser)) {
        fputs("oops", stderr);
        exit(3);
    }

    ErlNifBinary bin;
    enif_inspect_binary(env, argv[0], &bin);
    unsigned char* input = bin.data;
    size_t length = bin.size;

    yaml_parser_set_input_string(&parser, input, length);

    int index = 0, end = 0;
    ERL_NIF_TERM codes[30];

    do {
        if (!yaml_parser_parse(&parser, &event)) {
            fputs("oops", stderr);
        }

        switch (event.type) {
        case YAML_STREAM_START_EVENT:
            codes[index++] = enif_make_int(env, 1);
            break;
        case YAML_DOCUMENT_START_EVENT:
            codes[index++] = enif_make_int(env, 2);
            break;
        case YAML_ALIAS_EVENT:
            codes[index++] = enif_make_int(env, 3);
            break;
        case YAML_SCALAR_EVENT:
            codes[index++] = enif_make_int(env, 4);
            break;
        case YAML_SEQUENCE_START_EVENT:
            codes[index++] = enif_make_int(env, 5);
            break;
        case YAML_SEQUENCE_END_EVENT:
            codes[index++] = enif_make_int(env, 6);
            break;
        case YAML_MAPPING_START_EVENT:
            codes[index++] = enif_make_int(env, 7);
            break;
        case YAML_MAPPING_END_EVENT:
            codes[index++] = enif_make_int(env, 8);
            break;
        case YAML_DOCUMENT_END_EVENT:
            codes[index++] = enif_make_int(env, 9);
            break;
        case YAML_STREAM_END_EVENT:
            codes[index++] = enif_make_int(env, 10);
            end = 1;
            break;
        default:
            codes[index++] = enif_make_int(env, 0);
            break;
        }

        yaml_event_delete(&event);

    } while(!end);

    yaml_parser_delete(&parser);

    return enif_make_list_from_array(env, codes, index);
}

static int on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
    yomel_libyaml_type = enif_open_resource_type(
        env, "Elixir.Yomel.Nif", "yomel_libyaml_type",
        yomel_libyaml_destructor, ERL_NIF_RT_CREATE, NULL
    );

    return 0;
}

static ErlNifFunc nif_functions[] = {
    {"parse_string", 1, yomel_parse_string},
    {"initialize", 0, yomel_initialize},
    {"input_string", 2, yomel_input_string},
    {"next_event", 1, yomel_next_event}
};

ERL_NIF_INIT(Elixir.Yomel.Nif, nif_functions, on_load, 0, 0, NULL);

