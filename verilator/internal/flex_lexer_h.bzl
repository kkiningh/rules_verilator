"""Workaround for https://github.com/jmillikin/rules_flex/issues/1"""

load("@rules_flex//flex:flex.bzl", "flex_common")

def _flex_lexer_h(ctx):
    flex_toolchain = flex_common.flex_toolchain(ctx)
    flex_lexer_h = flex_toolchain.flex_lexer_h
    return CcInfo(compilation_context = cc_common.create_compilation_context(
        headers = depset(direct = [flex_lexer_h]),
        system_includes = depset(direct = [flex_lexer_h.dirname]),
    ))

flex_lexer_h = rule(_flex_lexer_h, toolchains = [
    flex_common.TOOLCHAIN_TYPE,
])
