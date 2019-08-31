load("@rules_verilator//verilator/internal:toolchain.bzl", "TOOLCHAIN_TYPE")
load("@rules_verilator//verilator/internal:versions.bzl", "VERSION_INFO")

[toolchain(
    name = "v{}".format(version),
    toolchain = "@rules_verilator//verilator/internal:toolchain_v{}".format(version),
    toolchain_type = TOOLCHAIN_TYPE,
) for version in VERSION_INFO.keys()]
