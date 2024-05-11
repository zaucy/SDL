load("@bazel_skylib//lib:selects.bzl", "selects")
load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

def sdl_setting(name, values):
    string_flag(
        name = name,
        visibility = ["//visibility:public"],
        build_setting_default = "auto",
        values = ["auto"],
    )
    for value in values:
        flag_values = {}
        flag_values[":{}".format(name)] = value
        native.config_setting(
            name = "use_{}_{}".format(name, value),
            flag_values = flag_values,
        )

def sdl_setting_auto_default(name, sdl_setting_name, constraint_values):
    flag_values = {}
    flag_values[":{}".format(sdl_setting_name)] = "auto"
    native.config_setting(
        name = "use_{}_auto_{}".format(sdl_setting_name, name),
        flag_values = flag_values,
        constraint_values = constraint_values,
    )

def sdl_config_substitutions(setting, value, auto_setting, define_name):
    enabled_subs = {}
    enabled_subs["#bazeldefine {}".format(define_name)] = "#ifdef {0}\n#undef {0}\n#endif //{0}\n#define {0} 1\n".format(define_name)
    disabled_subs = {}
    disabled_subs["#bazeldefine {}".format(define_name)] = "#ifdef {0}\n#undef {0}\n#endif //{0}\n#define {0} 0\n".format(define_name)
    return selects.with_or({
        (":use_{}_{}".format(setting, value), ":use_{}_auto_{}".format(setting, auto_setting)): enabled_subs,
        "//conditions:default": disabled_subs,
    })
