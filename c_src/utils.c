#include <erl_nif.h>
#include <yaml.h>
#include <string.h>

ERL_NIF_TERM utils_get_atom(ErlNifEnv* env, const char* name) {
    ERL_NIF_TERM atom;

    if (enif_make_existing_atom(env, name, &atom, ERL_NIF_LATIN1)) {
        return atom;
    }

    return enif_make_atom(env, name);
}

ERL_NIF_TERM utils_ok_atom(ErlNifEnv* env) {
    return utils_get_atom(env, "ok");
}

ERL_NIF_TERM utils_chars_to_binary(ErlNifEnv* env, const unsigned char* str, size_t len) {
    unsigned char* bin;
    ERL_NIF_TERM term;

    bin = enif_make_new_binary(env, len, &term);
    memcpy(bin, str, len);

    return term;
}

/**
 * transform characters to erlang binary.
 * return an atom :nil if given pointer is NULL.
 **/
ERL_NIF_TERM utils_nullable_chars_to_binary(ErlNifEnv* env, const unsigned char* str) {
    if (str == NULL) {
        return utils_get_atom(env, "nil");
    } else {
        return utils_chars_to_binary(env, str, strlen((const char *)str));
    }
}

ERL_NIF_TERM utils_scalar_style_to_atom(ErlNifEnv* env, yaml_scalar_style_t style) {
    switch (style) {
    case YAML_PLAIN_SCALAR_STYLE:
        return utils_get_atom(env, "plain");
    case YAML_SINGLE_QUOTED_SCALAR_STYLE:
        return utils_get_atom(env, "single_quoted");
    case YAML_DOUBLE_QUOTED_SCALAR_STYLE:
        return utils_get_atom(env, "double_quoted");
    case YAML_LITERAL_SCALAR_STYLE:
        return utils_get_atom(env, "literal");
    case YAML_FOLDED_SCALAR_STYLE:
        return utils_get_atom(env, "folded");
    case YAML_ANY_SCALAR_STYLE:
        return utils_get_atom(env, "any");
    }
}

ERL_NIF_TERM utils_sequence_style_to_atom(ErlNifEnv* env, yaml_sequence_style_t style) {
    switch (style) {
    case YAML_BLOCK_SEQUENCE_STYLE:
        return utils_get_atom(env, "block");
    case YAML_FLOW_SEQUENCE_STYLE:
        return utils_get_atom(env, "flow");
    case YAML_ANY_SEQUENCE_STYLE:
        return utils_get_atom(env, "any");
    }
}

ERL_NIF_TERM utils_mapping_style_to_atom(ErlNifEnv* env, yaml_mapping_style_t style) {
    switch (style) {
    case YAML_BLOCK_MAPPING_STYLE:
        return utils_get_atom(env, "block");
    case YAML_FLOW_MAPPING_STYLE:
        return utils_get_atom(env, "flow");
    case YAML_ANY_MAPPING_STYLE:
        return utils_get_atom(env, "any");
    }
}

