load("@bazel_skylib//lib:selects.bzl", "selects")
load("@bazel_skylib//rules:common_settings.bzl", "bool_flag", "string_flag")

def sdl_setting(name, values, multiple = False):
    if multiple:
        string_flag(
            name = name,
            visibility = ["//visibility:public"],
            build_setting_default = "auto",
            values = ["auto", "disabled", "explicit"],
        )
        for value in values:
            bool_flag(
                name = "{}_{}".format(name, value),
                visibility = ["//visibility:public"],
                build_setting_default = False,
            )
            native.config_setting(
                name = "use_{}_{}".format(name, value),
                flag_values = {":{}_{}".format(name, value): "true"},
            )
    else:
        string_flag(
            name = name,
            visibility = ["//visibility:public"],
            build_setting_default = "auto",
            values = ["auto", "disabled"] + values,
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

def sdl_config_substitutions(setting, value, defines = [], auto_setting = None):
    enabled_subs = {}
    for define in defines:
        enabled_subs["#bazeldefine {}\n".format(define)] = "#ifdef {0}\n#undef {0}\n#endif //{0}\n#define {0} 1\n".format(define)
    disabled_subs = {}
    for define in defines:
        disabled_subs["#bazeldefine {}\n".format(define)] = "#ifdef {0}\n#undef {0}\n#endif //{0}\n".format(define)
    if auto_setting != None:
        return selects.with_or({
            (":use_{}_{}".format(setting, value), ":use_{}_auto_{}".format(setting, auto_setting)): enabled_subs,
            "//conditions:default": disabled_subs,
        })
    else:
        return selects.with_or({
            (":use_{}_{}".format(setting, value)): enabled_subs,
            "//conditions:default": disabled_subs,
        })

def sdl_config_substitutions_todo(defines):
    disabled_subs = {}
    for define in defines:
        disabled_subs["#bazeldefine {}\n".format(define)] = "#ifdef {0}\n#undef {0}\n#endif //{0}\n// TODO: currently {0} is not configurable in bazel\n".format(define)
    return disabled_subs
