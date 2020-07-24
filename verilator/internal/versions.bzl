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
    _info("4.034", "54ed7b06ee28b5d21f9d0ee98406d29a508e6124b0d10e54bb32081613ddb80b"),
])

DEFAULT_VERSION = "4.034"

def version_info(version):
    if version not in VERSION_INFO:
        fail("Verilator version {} not supported by rules_verilator.".format(repr(version)))
    return VERSION_INFO[version]
