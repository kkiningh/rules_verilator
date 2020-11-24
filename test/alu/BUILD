load("@rules_verilog//verilog:defs.bzl", "verilog_module")
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

cc_binary(
    name = "alu_bin",
    srcs = ["alu.cpp"],
    deps = [":alu"],
)

verilog_module(
    name = "alu_module",
    srcs = ["alu.sv"],
    top = "alu",
)

verilator_cc_library(
    name = "alu_with_module",
    module = ":alu_module",
)

cc_binary(
    name = "alu_bin_with_module",
    srcs = ["alu.cpp"],
    deps = [":alu_with_module"],
)
