load(
    "@rules_verilator//verilator/internal:cc_actions.bzl",
    "cc_compile_and_link_static_library",
)
load(
    "@rules_verilator//verilator/internal:toolchain.bzl",
    _TOOLCHAIN_TYPE = "TOOLCHAIN_TYPE",
)

# Provider for verilog libraries
VerilogInfo = provider(fields = ["transitive_sources"])

def get_transitive_sources(srcs, deps):
    """Obtain the underlying source files for a target and it's transitive
    dependencies.

    Args:
      srcs: a list of source files
      deps: a list of targets that are the direct dependencies
    Returns:
      a collection of the transitive sources
    """
    return depset(
        direct = srcs,
        transitive = [dep[VerilogInfo].transitive_sources for dep in deps],
    )

def _sv_library(ctx):
    transitive_sources = get_transitive_sources(ctx.files.srcs, ctx.attr.deps)
    return [VerilogInfo(transitive_sources = transitive_sources)]

sv_library = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".v", ".sv"],
        ),
        "deps": attr.label_list(providers = [VerilogInfo]),
    },
    implementation = _sv_library,
)

_CPP_SRC = ["cc", "cpp", "cxx", "c++"]
_HPP_SRC = ["h", "hh", "hpp"]

def _only_cpp(f):
    """Filter for just C++ source/headers"""
    if f.extension in _CPP_SRC + _HPP_SRC:
        return f.path
    return None

def _only_hpp(f):
    """Filter for just C++ headers"""
    if f.extension in _HPP_SRC:
        return f.path
    return None

_COPY_TREE_SH = """
OUT=$1; shift && mkdir -p "$OUT" && cp $* "$OUT"
"""

def _copy_tree(ctx, idir, odir, map_each = None, progress_message = None):
    """Copy files from a TreeArtifact to a new directory"""
    args = ctx.actions.args()
    args.add(odir.path)
    args.add_all([idir], map_each = map_each)
    ctx.actions.run_shell(
        arguments = [args],
        command = _COPY_TREE_SH,
        inputs = [idir],
        outputs = [odir],
        progress_message = progress_message,
    )

    return odir

def _verilator_cc_library(ctx):
    """Produce a static library and C++ header files from a Verilog library"""
    # Get the verilator toolchain
    verilator_toolchain = ctx.toolchains[_TOOLCHAIN_TYPE].verilator_toolchain

    # Gather all the Verilog source files, including transitive dependencies
    srcs = get_transitive_sources(
        ctx.files.srcs + ctx.files.hdrs,
        ctx.attr.deps,
    )

    # Default Verilator output prefix (e.g. "Vtop")
    mtop = ctx.label.name if ctx.attr.mtop == None else ctx.attr.mtop
    prefix = ctx.attr.prefix + ctx.attr.mtop

    # Output directories/files
    verilator_output = ctx.actions.declare_directory(prefix + "-gen")
    verilator_output_cpp = ctx.actions.declare_directory(prefix + ".cpp")
    verilator_output_hpp = ctx.actions.declare_directory(prefix + ".h")

    # Run Verilator
    args = ctx.actions.args()
    if ctx.attr.sysc:
        args.add("--sc")
    else:
        args.add("--cc")
    args.add("--Mdir", verilator_output.path)
    args.add("--prefix", prefix)
    args.add("--top-module", mtop)
    if ctx.attr.trace:
        args.add("--trace")
    args.add_all(srcs)
    args.add_all(ctx.attr.vopts, expand_directories = False)
    ctx.actions.run(
        arguments = [args],
        executable = verilator_toolchain.verilator_executable,
        inputs = srcs,
        outputs = [verilator_output],
        progress_message = "[Verilator] Compiling {}".format(ctx.label),
    )

    # Extract out just C++ files
    # Work around for https://github.com/bazelbuild/bazel/pull/8269
    _copy_tree(
        ctx,
        verilator_output,
        verilator_output_cpp,
        map_each = _only_cpp,
        progress_message = "[Verilator] Extracting C++ source files",
    )
    _copy_tree(
        ctx,
        verilator_output,
        verilator_output_hpp,
        map_each = _only_hpp,
        progress_message = "[Verilator] Extracting C++ header files",
    )

    # Collect the verilator ouput and, if needed, generate a driver program
    srcs = [verilator_output_cpp]
    hdrs = [verilator_output_hpp]

    # Do actual compile
    defines = ["VM_TRACE"] if ctx.attr.trace else []
    deps = list(verilator_toolchain.libs)
    #if ctx.attr.sysc:
    #    deps.append(ctx.attr._systemc)

    return cc_compile_and_link_static_library(
        ctx,
        srcs = srcs,
        hdrs = hdrs,
        defines = defines,
        deps = deps,
    )

verilator_cc_library = rule(
    _verilator_cc_library,
    attrs = {
        "srcs": attr.label_list(
            doc = "List of verilog source files",
            mandatory = False,
            allow_files = [".v", ".sv"],
        ),
        "hdrs": attr.label_list(
            doc = "List of verilog header files",
            allow_files = [".v", ".sv", ".vh", ".svh"],
        ),
        "deps": attr.label_list(
            doc = "List of verilog and C++ dependencies",
        ),
        "mtop": attr.string(
            doc = "Top level module. Defaults to the rule name if not specified",
            mandatory = False,
        ),
        "trace": attr.bool(
            doc = "Enable tracing for Verilator",
            default = False,
        ),
        "prefix": attr.string(
            doc = "Prefix for generated C++ headers and classes",
            default = "V",
        ),
        "sysc": attr.bool(
            doc = "Generate SystemC using the --sc Verilator option",
            default = False,
        ),
        "vopts": attr.string_list(
            doc = "Additional command line options to pass to Verilator",
            default = ["-Wall"],
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    provides = [
        CcInfo,
        DefaultInfo,
    ],
    toolchains = [
        "@bazel_tools//tools/cpp:toolchain_type",
        "@rules_verilator//verilator:toolchain_type",
    ],
    fragments = ["cpp"],
)
