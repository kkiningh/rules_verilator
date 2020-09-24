"""Helpers for finding the repository information for a specific version"""

_MIRROR_URLS = [
    "https://github.com/verilator/verilator/archive/{}.tar.gz",
]

def _urls(version):
    if version != "master":
        version = 'v' + version
    return [m.format(version) for m in _MIRROR_URLS]

def _info(version, sha256):
    return (version, struct(
        sha256 = sha256,
        strip_prefix = "verilator-{}".format(version),
        urls = _urls(version),
    ))

VERSION_INFO = dict([
    _info("4.034", "17a087fc74fd1ab035a43ba38d6f6198150ee11b20077855404ddb4c1620c6b7"),
    _info("4.036", "856b365ffb803f211960761dee263bb06d893a780bee3cbc8c2575a6c0030da1"),
    _info("4.038", "0a4a11ae9ca64aa995b1c5895e4367043a72fa4cf89a6781b6877b0f78b27863"),
    _info("4.100", "031ddd24be38a996e9dc3cf8591fca7cd06b7d21b88e5648ead386d3ec445ba3"),
    _info("master", ""),  # Hash omitted. Use at your own risk.
])

DEFAULT_VERSION = "4.100"

def version_info(version):
    if version not in VERSION_INFO:
        fail("Verilator version {} not supported by rules_verilator.".format(repr(version)))
    return VERSION_INFO[version]
