#!/usr/bin/env bash
# Build geosite.dat locally — mirrors the GitHub Actions pipeline.
# Requires: Go 1.21+, git
#
# Usage: ./build.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK=/tmp/geosite-ru-smart-build
rm -rf "$WORK"
mkdir -p "$WORK"

echo "==> Checking routing consistency (no shadowed entries)..."
"$REPO_DIR/check-consistency.sh"

echo "==> Cloning v2fly/domain-list-community builder..."
git clone --depth 1 https://github.com/v2fly/domain-list-community.git "$WORK/community"

echo "==> Overlaying our data/ on top of v2fly community/data (ours wins on conflict)"
cp -a "$REPO_DIR/data/." "$WORK/community/data/"

echo "==> Building geosite.dat..."
mkdir -p "$WORK/out"
(cd "$WORK/community" && go run ./ -outputdir="$WORK/out")

test -s "$WORK/out/dlc.dat" || { echo "BUILD FAILED"; exit 1; }

mkdir -p "$REPO_DIR/release"
cp -f "$WORK/out/dlc.dat" "$REPO_DIR/release/geosite.dat"

SIZE=$(wc -c < "$REPO_DIR/release/geosite.dat")
echo ""
echo "=========================================="
echo "✅ Built: $REPO_DIR/release/geosite.dat"
echo "   Size: $SIZE bytes"
echo "=========================================="
