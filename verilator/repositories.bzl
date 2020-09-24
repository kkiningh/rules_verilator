load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "@rules_verilator//verilator/internal:versions.bzl",
    _DEFAULT_VERSION = "DEFAULT_VERSION",
    _version_info = "version_info",
)

def _verilator_repository(ctx):
    info = _version_info(ctx.attr.version)
    ctx.download_and_extract(
        url = info.urls,
        sha256 = info.sha256,
        stripPrefix = info.strip_prefix,
    )

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(name = repr(ctx.name)))
    ctx.symlink(ctx.attr._buildfile, "BUILD")

    # Generate files usually produced / modified by autotools.
    replace = {
        "#define PACKAGE_STRING \"\"": "#define PACKAGE_STRING \"Verilator v{}\"".format(
                ctx.attr.version),
    }
    ctx.template("src/config_build.h", "src/config_build.h.in", replace, executable = False)

    ctx.file("src/config_rev.h",
             "static const char* const DTVERSION_rev = \"v{}\";\n".format(ctx.attr.version))

    replace = {
        "@PACKAGE_NAME@": "Verilator",
        "@PACKAGE_VERSION@": ctx.attr.version,
    }
    ctx.template("include/verilated_config.h", "include/verilated_config.h.in", replace,
                 executable = False)

verilator_repository = repository_rule(
    _verilator_repository,
    attrs = {
        "version": attr.string(mandatory = True),
        "_buildfile": attr.label(
            default = Label("@rules_verilator//verilator/internal:verilator.BUILD"),
        ),
    },
)

def rules_verilator_dependencies(version = _DEFAULT_VERSION):
    _maybe(
        http_archive,
        name = "rules_m4",
        urls = ["https://github.com/jmillikin/rules_m4/releases/download/v0.1/rules_m4-v0.1.tar.xz"],
        sha256 = "7bb12b8a5a96037ff3d36993a9bb5436c097e8d1287a573d5958b9d054c0a4f7",
    )
    _maybe(
        http_archive,
        name = "rules_flex",
        urls = ["https://github.com/jmillikin/rules_flex/releases/download/v0.1/rules_flex-v0.1.tar.xz"],
        sha256 = "361b14db1569d555afd2a69984e27b83ccfc63a3d50e9a7c15ac8fa973406d0d",
    )
    _maybe(
        http_archive,
        name = "rules_bison",
        urls = ["https://github.com/jmillikin/rules_bison/releases/download/v0.1/rules_bison-v0.1.tar.xz"],
        sha256 = "5c57552a129b0d8eeb9252341ee975ec2720c35baf2f0d154756310c1ff572a0",
    )

def rules_verilator_toolchains(version = _DEFAULT_VERSION):
    repo_name = "verilator_v{version}".format(version = version)
    _maybe(verilator_repository, name = repo_name, version = version)
    native.register_toolchains("@rules_verilator//verilator/toolchains:v{}".format(version))

def _maybe(repo_rule, **kwargs):
    if kwargs["name"] not in native.existing_rules():
        repo_rule(**kwargs)
