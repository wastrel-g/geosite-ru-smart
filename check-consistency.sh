#!/usr/bin/env bash
# Catch routing conflicts BEFORE they reach production.
#
# In our routing model (RouteOrder: block-proxy-direct):
#   - block wins over proxy and direct
#   - proxy wins over direct
# So if a domain ends up in more than one bucket, the earlier bucket silently
# shadows the later ones. This script enforces that each domain only lives in
# one bucket.
#
# Runs as part of CI and ./build.sh. Exit 1 on any conflict.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR/data"

DIRECT_FILES=(ru-banks ru-scanners ru-ipcheck ru-gov ru-ecosystem ru-marketplaces ru-games ru-apple-push)
PROXY_FILES=(rkn-social rkn-media rkn-ai rkn-audio rkn-vpn-info)
BLOCK_FILES=(block-ads block-torrent)

dom() { grep -hoE '^domain:[^ ]+$' "$@" | sort -u; }

DIRECT_DOMS=$(dom "${DIRECT_FILES[@]}")
PROXY_DOMS=$(dom "${PROXY_FILES[@]}")
BLOCK_DOMS=$(dom "${BLOCK_FILES[@]}")

fail=0
check() {
  local label="$1" out="$2"
  if [ -n "$out" ]; then
    echo "FAIL: $label"
    echo "$out" | sed 's/^/    /'
    fail=1
  fi
}

# Intra-bucket duplicates (cosmetic, but wastes bytes and signals drift).
check "intra-direct dupes" "$(grep -hoE '^domain:[^ ]+$' "${DIRECT_FILES[@]}" | sort | uniq -d)"
check "intra-proxy dupes"  "$(grep -hoE '^domain:[^ ]+$' "${PROXY_FILES[@]}"  | sort | uniq -d)"
check "intra-block dupes"  "$(grep -hoE '^domain:[^ ]+$' "${BLOCK_FILES[@]}"  | sort | uniq -d)"

# Cross-bucket conflicts (functional — block/proxy would shadow direct).
check "direct ∩ block (shadowed direct)" "$(comm -12 <(echo "$DIRECT_DOMS") <(echo "$BLOCK_DOMS"))"
check "proxy ∩ direct (shadowed direct)"  "$(comm -12 <(echo "$PROXY_DOMS")  <(echo "$DIRECT_DOMS"))"
check "proxy ∩ block  (shadowed proxy)"   "$(comm -12 <(echo "$PROXY_DOMS")  <(echo "$BLOCK_DOMS"))"

if [ $fail -eq 0 ]; then
  direct_n=$(echo "$DIRECT_DOMS" | wc -l | tr -d ' ')
  proxy_n=$(echo "$PROXY_DOMS" | wc -l | tr -d ' ')
  block_n=$(echo "$BLOCK_DOMS" | wc -l | tr -d ' ')
  echo "✓ consistency OK — ${direct_n} direct / ${proxy_n} proxy / ${block_n} block, no conflicts"
fi

exit $fail
