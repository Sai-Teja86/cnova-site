#!/bin/sh
# Vaultgate connector installer for Linux (systemd; x86-64 or ARM64). Run as root:
#   curl -fsSL https://cnova.in/connector/install.sh | sudo sh -s -- 'vgc1...'
# Downloads the connector program, checks its SHA-256 against the value below, installs it as the
# vaultgate-connector service and enrolls it with the code. Nothing else is changed on this machine.
set -eu
VERSION='0.2.0'
SHA_AMD64='e9e241a2804279528b5f500383a652acb4a3e78fa9f78455d6d5c87a106ac4cb'
SHA_ARM64='6e1dbe186ee72c151ce9380fec914d0375290678ac9533e3fcefb55d9e3667a1'
BASE="${VAULTGATE_CONNECTOR_BASE:-https://cnova.in/connector}"  # tests only: the SHA-256 is checked either way
CODE="${1:-}"
[ "$(id -u)" = 0 ] || { echo "Run it as root, for example with sudo." >&2; exit 1; }
command -v systemctl >/dev/null || { echo "This needs a Linux machine with systemd." >&2; exit 1; }
case "$(uname -m)" in
  x86_64|amd64) arch=amd64; sha=$SHA_AMD64 ;;
  aarch64|arm64) arch=arm64; sha=$SHA_ARM64 ;;
  *) echo "Unsupported processor: $(uname -m) (x86-64 and ARM64 only)." >&2; exit 1 ;;
esac
if [ -z "$CODE" ]; then
  printf 'Paste the connector code from Vaultgate (Configuration > Connectors): ' >&2
  read -r CODE < /dev/tty
fi
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
echo "Downloading the Vaultgate connector $VERSION ($arch) ..."
curl -fsSL "$BASE/vaultgate-connector-$VERSION-linux-$arch" -o "$tmp/vaultgate-connector"
echo "$sha  $tmp/vaultgate-connector" | sha256sum -c --quiet - || { echo "The download doesn't match its published SHA-256: not installed." >&2; exit 1; }
chmod 755 "$tmp/vaultgate-connector"
"$tmp/vaultgate-connector" install --code "$CODE"
