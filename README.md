# Bazel build rules for Verilator

## Overview

Add the following to your `WORKSPACE` file

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Verilator
http_archive(
    name = "rules_verilator",
    # See release page for latest urls + sha
)

load(
    "@rules_verilator//verilator:repositories.bzl",
    "rules_verilator_dependencies",
    "rules_verilator_toolchains"
)
rules_verilator_dependencies()
rules_verilator_toolchains()

# Register toolchain dependencies
load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()

load("@rules_flex//flex:flex.bzl", "flex_register_toolchains")
flex_register_toolchains()

load("@rules_bison//bison:bison.bzl", "bison_register_toolchains")
bison_register_toolchains()
```

### Supported Bazel Versions

These rules are under active development and the minimum supported Bazel version may change.
Currently, the `master` branch requires [Bazel >= 3.0.0](https://blog.bazel.build/2020/03/31/bazel-3.0.html).

## Build rules

```python
load("@rules_verilator//verilator:defs.bzl", "verilator_cc_library")

verilator_cc_library(
    name = "alu",
    mtop = "alu", # defaults to name if not specified
    srcs = ["alu.sv"],
)

cc_binary(
    name = "alu_bin",
    srcs = ["alu.cpp"],
    deps = [":alu"],
)
```

The details of a verilog module (sources, top name, etc.) can also be specified by a `verilog_module`
which can be reused in other rules.

```python
load("@rules_verilog//verilog:defs.bzl", "verilog_module")

load("@rules_verilator//verilator:defs.bzl", "verilator_cc_library")

verilog_module(
    name = "alu_module",
    top = "alu",
    srcs = ["alu.sv"],
)

verilator_cc_library(
    name = "alu",
    module = ":alu_module",
)
```

See [test/alu/BUILD](test/alu/BUILD) for working examples.

## License

Released under Apache 2.0.
