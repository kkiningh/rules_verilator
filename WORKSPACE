workspace(name = "rules_verilator")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "@rules_verilator//verilator:repositories.bzl",
    "rules_verilator_dependencies",
    "local_rules_verilator_toolchains",
    "rules_verilator_toolchains"
)

rules_verilator_dependencies()

#local_rules_verilator_toolchains(path="temp/verilator")
rules_verilator_toolchains()
load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")

m4_register_toolchains()

load("@rules_flex//flex:flex.bzl", "flex_register_toolchains")

flex_register_toolchains()

load("@rules_bison//bison:bison.bzl", "bison_register_toolchains")

bison_register_toolchains()
