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

The rules also depend on the experimental C++ skylark API, which can be enabled by adding the following to your project's `.bazelrc`

```
build --experimental_cc_skylark_api_enabled_packages=@rules_verilator//verilator/internal
```

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

Verilog libraries can also be specifed as dependencies

```python
load("@rules_verilator//verilator:defs.bzl", "sv_library", "verilator_cc_library")

sv_library(
    name = "alu_lib",
    srcs = ["alu.sv"],
)

verilator_cc_library(
    name = "alu",
    mtop = "alu",
    deps = [":alu_lib"],
)
```

## License

Released under Apache 2.0.
