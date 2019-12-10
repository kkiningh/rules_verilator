"""Helpers for finding the repository information for a specific version"""

_MIRROR_URLS = [
    "https://www.veripool.org/ftp/",
]

def _urls(filename):
    return [m + filename for m in _MIRROR_URLS]

def _info(version, sha256):
    return (version, struct(
        sha256 = sha256,
        strip_prefix = "verilator-{}".format(version),
        urls = _urls("verilator-{}.tgz".format(version)),
    ))




VERSION_INFO = dict([
    _info("4.018", "98d52ec125d21b452a8b0bfddf336d8f792a53449db26798978f47885a430346"),
    _info("4.016", ""),
    _info("4.014", ""),
    _info("local",""),
])

DEFAULT_VERSION = "4.018"

def version_info(version):
    if version not in VERSION_INFO:
        fail("Verilator version {} not supported by rules_verilator.".format(repr(version)))
    return VERSION_INFO[version]
