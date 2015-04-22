#ifndef UTIL_H
#define UTIL_H

ERL_NIF_TERM utils_get_atom(ErlNifEnv*, const char*);
ERL_NIF_TERM utils_ok_atom(ErlNifEnv*);
ERL_NIF_TERM utils_chars_to_binary(ErlNifEnv*, const unsigned char*, size_t);
ERL_NIF_TERM utils_nullable_chars_to_binary(ErlNifEnv*, const unsigned char*);
ERL_NIF_TERM utils_scalar_style_to_atom(ErlNifEnv*, yaml_scalar_style_t);
ERL_NIF_TERM utils_sequence_style_to_atom(ErlNifEnv* env, yaml_sequence_style_t);
ERL_NIF_TERM utils_mapping_style_to_atom(ErlNifEnv* env, yaml_mapping_style_t);

#endif
