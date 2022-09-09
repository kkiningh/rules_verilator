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
            ctx.attr.version,
        ),
    }
    ctx.template("src/config_build.h", "src/config_build.h.in", replace, executable = False)

    ctx.file(
        "src/config_rev.h",
        "static const char* const DTVERSION_rev = \"v{}\";\n".format(ctx.attr.version),
    )

    replace = {
        "@PACKAGE_NAME@": "Verilator",
        "@PACKAGE_VERSION@": ctx.attr.version,
    }
    ctx.template(
        "include/verilated_config.h",
        "include/verilated_config.h.in",
        replace,
        executable = False,
    )

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
        urls = ["https://github.com/jmillikin/rules_m4/releases/download/v0.2.2/rules_m4-v0.2.2.tar.xz"],
        sha256 = "b0309baacfd1b736ed82dc2bb27b0ec38455a31a3d5d20f8d05e831ebeef1a8e",
    )
    _maybe(
        http_archive,
        name = "rules_flex",
        urls = ["https://github.com/jmillikin/rules_flex/releases/download/v0.2/rules_flex-v0.2.tar.xz"],
        sha256 = "f1685512937c2e33a7ebc4d5c6cf38ed282c2ce3b7a9c7c0b542db7e5db59d52",
    )
    _maybe(
        http_archive,
        name = "rules_bison",
        urls = ["https://github.com/jmillikin/rules_bison/releases/download/v0.2.1/rules_bison-v0.2.1.tar.xz"],
        sha256 = "9577455967bfcf52f9167274063ebb74696cb0fd576e4226e14ed23c5d67a693",
    )
    _maybe(
        http_archive,
        name = "rules_verilog",
        urls = ["https://github.com/agoessling/rules_verilog/archive/v0.1.0.zip"],
        strip_prefix = "rules_verilog-0.1.0",
        sha256 = "401b3f591f296f6fd2f6656f01afc1f93111e10b81b9a9d291f9c04b3e4a3e8b",
    )

def rules_verilator_toolchains(version = _DEFAULT_VERSION):
    repo_name = "verilator_v{version}".format(version = version)
    _maybe(verilator_repository, name = repo_name, version = version)
    native.register_toolchains("@rules_verilator//verilator/toolchains:v{}".format(version))

def _maybe(repo_rule, **kwargs):
    if kwargs["name"] not in native.existing_rules():
        repo_rule(**kwargs)
