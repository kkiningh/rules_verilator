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

### Note for Bazel versions prior to 1.2

If you are building with Bazel pre [version 1.2](https://blog.bazel.build/2019/11/20/bazel-1.2.0.html)), the following flag must be added to your project's `.bazelrc`.

```
build --experimental_cc_skylark_api_enabled_packages=@rules_verilator//verilator/internal
```

This enables the Starlark C++ API, which the rules depend on.

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
