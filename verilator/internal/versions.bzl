"""Helpers for finding the repository information for a specific version"""

_MIRROR_URLS = [
    "https://github.com/verilator/verilator/archive/{}.tar.gz",
]

def _urls(version):
    if version != "master":
        version = "v" + version
    return [m.format(version) for m in _MIRROR_URLS]

def _info(version, sha256):
    return (version, struct(
        sha256 = sha256,
        strip_prefix = "verilator-{}".format(version),
        urls = _urls(version),
    ))

VERSION_INFO = dict([
    _info("4.224", "010ff2b5c76d4dbc2ed4a3278a5599ba35c8ed4c05690e57296d6b281591367b"),
    _info("master", ""),  # Hash omitted. Use at your own risk.
])

DEFAULT_VERSION = "4.224"

def version_info(version):
    if version not in VERSION_INFO:
        fail("Verilator version {} not supported by rules_verilator.".format(repr(version)))
    return VERSION_INFO[version]
