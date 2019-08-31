load("@rules_verilator//verilator/internal:toolchain.bzl", "verilator_toolchain_info")
load("@rules_verilator//verilator/internal:versions.bzl", "VERSION_INFO")

[verilator_toolchain_info(
		name = "toolchain_v{}".format(version),
		verilator = "@verilator_v{}//:verilator_executable".format(version),
    libs = [
        "@verilator_v{}//:libverilator".format(version),
        "@verilator_v{}//:svdpi".format(version),
    ],
		visibility = ["//visibility:public"],
) for version in VERSION_INFO.keys()]
