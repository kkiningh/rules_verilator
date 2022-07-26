"""Rules for compiling Verilog files to C++ using Verilator"""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

def cc_compile_and_link_static_library(ctx, srcs, hdrs, deps, includes = [], defines = []):
    """Compile and link C++ source into a static library"""
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    compilation_contexts = [dep[CcInfo].compilation_context for dep in deps]
    compilation_context, compilation_outputs = cc_common.compile(
        name = ctx.label.name,
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        srcs = srcs,
        includes = includes,
        defines = defines,
        public_hdrs = hdrs,
        compilation_contexts = compilation_contexts,
    )

    linking_contexts = [dep[CcInfo].linking_context for dep in deps]
    linking_context, linking_output = cc_common.create_linking_context_from_compilation_outputs(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = compilation_outputs,
        linking_contexts = linking_contexts,
        name = ctx.label.name,
    )

    output_files = []
    if linking_output.library_to_link.static_library != None:
        output_files.append(linking_output.library_to_link.static_library)
    if linking_output.library_to_link.dynamic_library != None:
        output_files.append(linking_output.library_to_link.dynamic_library)

    return [
        DefaultInfo(files = depset(output_files)),
        CcInfo(
            compilation_context = compilation_context,
            linking_context = linking_context,
        ),
    ]
