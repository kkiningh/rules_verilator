TOOLCHAIN_TYPE = "@rules_verilator//verilator:toolchain_type"

ToolchainInfo = provider(fields = ["files", "libs", "vars", "verilator_executable"])

def _verilator_toolchain_info(ctx):
  runfiles = ctx.attr.verilator[DefaultInfo].default_runfiles.files
  toolchain = ToolchainInfo(
      files = depset(
          direct = [ctx.executable.verilator],
          transitive = [runfiles],
      ),
      libs = ctx.attr.libs,
      vars = {},
      verilator_executable = ctx.executable.verilator,
  )

  return [
      platform_common.ToolchainInfo(verilator_toolchain = toolchain),
      platform_common.TemplateVariableInfo(toolchain.vars),
  ]

verilator_toolchain_info = rule(
    _verilator_toolchain_info,
    attrs = {
        "verilator": attr.label(
            doc = "Verilator binary",
            mandatory = True,
            executable = True,
            cfg = "host",
        ),
        "libs": attr.label_list(
            doc = "List of runtime libraries required for Verilator programs",
            mandatory = True,
            allow_empty = False,
            providers = [CcInfo],
            cfg = "target",
        ),
    },
    provides = [
        platform_common.ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)

def _verilator_toolchain_alias(ctx):
    toolchain = ctx.toolchains[TOOLCHAIN_TYPE].verilator_toolchain
    return [
        DefaultInfo(files = toolchain.files),
        toolchain,
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

verilator_toolchain_alias = rule(
    _verilator_toolchain_alias,
    toolchains = [TOOLCHAIN_TYPE],
    provides = [
				DefaultInfo,
				ToolchainInfo,
				platform_common.TemplateVariableInfo,
    ],
)
