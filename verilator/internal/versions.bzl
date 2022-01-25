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
    _info("4.218", "ef7b1e6ddb715ddb3cc998fcbefc7150cfa2efc5118cf43ddb594bf41ea41cc7"),
    _info("master", ""),  # Hash omitted. Use at your own risk.
])

DEFAULT_VERSION = "4.218"

def version_info(version):
    if version not in VERSION_INFO:
        fail("Verilator version {} not supported by rules_verilator.".format(repr(version)))
    return VERSION_INFO[version]
