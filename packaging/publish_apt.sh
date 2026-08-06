#!/usr/bin/env bash
#
# Builds (or refreshes) the signed APT repository served from GitHub Pages.
#
#   packaging/publish_apt.sh <output-dir> <deb> [<deb>...]
#
# The output directory is the gh-pages worktree. Existing pool entries are kept,
# so publishing a new version leaves older ones installable and `apt upgrade`
# has something to compare against.
#
# Signing needs a private key in the environment:
#   APT_GPG_PRIVATE_KEY   ASCII-armoured private key
#   APT_GPG_PASSPHRASE    its passphrase (optional if the key has none)
#
# Without a key the repository is still generated but left unsigned, which is
# enough to test the layout locally; apt itself will refuse an unsigned repo.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OUTPUT="${1:?usage: publish_apt.sh <output-dir> <deb>...}"
shift
if [[ $# -eq 0 ]]; then
  echo "no .deb files given" >&2
  exit 2
fi

ORIGIN="Paint"
LABEL="Paint"
SUITE="stable"
COMPONENT="main"
ARCHITECTURES="amd64"
PAGES_URL="${PAGES_URL:-https://rbuache.github.io/paint}"
KEYRING_NAME="paint-archive-keyring.gpg"

mkdir -p "$OUTPUT/pool/$COMPONENT/p/paint"
for deb in "$@"; do
  cp -f "$deb" "$OUTPUT/pool/$COMPONENT/p/paint/"
done

for arch in $ARCHITECTURES; do
  mkdir -p "$OUTPUT/dists/$SUITE/$COMPONENT/binary-$arch"
done

cd "$OUTPUT"

# apt-ftparchive walks pool/ and writes the package index. Paths in the index
# must be relative to the repository root, hence running from here.
for arch in $ARCHITECTURES; do
  apt-ftparchive --arch "$arch" packages pool \
    > "dists/$SUITE/$COMPONENT/binary-$arch/Packages"
  gzip -9nkf "dists/$SUITE/$COMPONENT/binary-$arch/Packages"
done

cat > "$OUTPUT/apt-ftparchive-release.conf" <<CONF
APT::FTPArchive::Release::Origin "$ORIGIN";
APT::FTPArchive::Release::Label "$LABEL";
APT::FTPArchive::Release::Suite "$SUITE";
APT::FTPArchive::Release::Codename "$SUITE";
APT::FTPArchive::Release::Architectures "$ARCHITECTURES";
APT::FTPArchive::Release::Components "$COMPONENT";
APT::FTPArchive::Release::Description "Paint image editor";
CONF

# Written outside the tree first: the shell would otherwise create an empty
# Release before apt-ftparchive scans the directory, and it would hash that
# placeholder into its own index.
rm -f "dists/$SUITE/Release" "dists/$SUITE/InRelease" "dists/$SUITE/Release.gpg"
RELEASE_TMP="$(mktemp)"
apt-ftparchive -c "$OUTPUT/apt-ftparchive-release.conf" \
  release "dists/$SUITE" > "$RELEASE_TMP"
mv "$RELEASE_TMP" "dists/$SUITE/Release"
rm -f "$OUTPUT/apt-ftparchive-release.conf"

if [[ -n "${APT_GPG_PRIVATE_KEY:-}" ]]; then
  GNUPGHOME="$(mktemp -d)"
  export GNUPGHOME
  chmod 700 "$GNUPGHOME"
  printf '%s' "$APT_GPG_PRIVATE_KEY" | gpg --batch --quiet --import

  KEY_ID="$(gpg --list-secret-keys --with-colons | awk -F: '/^sec:/ {print $5; exit}')"
  if [[ -z "$KEY_ID" ]]; then
    echo "the supplied APT_GPG_PRIVATE_KEY contains no secret key" >&2
    exit 1
  fi

  GPG_ARGS=(--batch --yes --quiet --local-user "$KEY_ID")
  if [[ -n "${APT_GPG_PASSPHRASE:-}" ]]; then
    GPG_ARGS+=(--pinentry-mode loopback --passphrase "$APT_GPG_PASSPHRASE")
  fi

  # Both signatures are produced: InRelease for modern apt, Release.gpg for
  # older clients that still look for a detached signature.
  gpg "${GPG_ARGS[@]}" --clearsign \
    --output "dists/$SUITE/InRelease" "dists/$SUITE/Release"
  gpg "${GPG_ARGS[@]}" --armor --detach-sign \
    --output "dists/$SUITE/Release.gpg" "dists/$SUITE/Release"

  # The public key is published in binary (dearmoured) form, which is what
  # signed-by= expects in /etc/apt/keyrings.
  gpg --batch --yes --export "$KEY_ID" > "$KEYRING_NAME"

  rm -rf "$GNUPGHOME"
  unset GNUPGHOME
  echo "signed with $KEY_ID"
else
  echo "warning: APT_GPG_PRIVATE_KEY is not set; repository left unsigned" >&2
fi

# A ready-made deb822 source file, so installing is two commands rather than a
# hand-written sources.list line.
cat > "$OUTPUT/paint.sources" <<SOURCES
Types: deb
URIs: $PAGES_URL
Suites: $SUITE
Components: $COMPONENT
Architectures: $ARCHITECTURES
Signed-By: /etc/apt/keyrings/paint.gpg
SOURCES

cat > "$OUTPUT/index.html" <<HTML
<!doctype html>
<meta charset="utf-8">
<title>Paint — APT repository</title>
<style>
  body { font-family: system-ui, sans-serif; max-width: 46rem; margin: 3rem auto;
         padding: 0 1rem; line-height: 1.55; color: #22262c; }
  pre { background: #f4f5f7; padding: 1rem; overflow-x: auto; border-radius: 6px; }
  code { font-family: ui-monospace, monospace; }
  @media (prefers-color-scheme: dark) {
    body { background: #16181b; color: #dfe3e8; }
    pre { background: #22262b; }
  }
</style>
<h1>Paint — APT repository</h1>
<p>A simple, easy-to-use image editor for Linux.</p>
<h2>Install</h2>
<pre><code>sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL $PAGES_URL/$KEYRING_NAME \\
  | sudo tee /etc/apt/keyrings/paint.gpg > /dev/null
sudo curl -fsSL -o /etc/apt/sources.list.d/paint.sources \\
  $PAGES_URL/paint.sources
sudo apt update
sudo apt install paint</code></pre>
<h2>Update</h2>
<pre><code>sudo apt update &amp;&amp; sudo apt upgrade</code></pre>
<p><a href="https://github.com/rbuache/paint">Source code and releases</a></p>
HTML

# GitHub Pages runs Jekyll by default, which would skip the dists/ directory
# because of its underscore-free but dotfile-adjacent contents; this disables it.
touch "$OUTPUT/.nojekyll"

echo "APT repository written to $OUTPUT"
find "$OUTPUT/dists" "$OUTPUT/pool" -type f | sort | sed 's/^/  /'
