#!/bin/bash

# Betroffene Versionen
MALICIOUS_VERSIONS=("1.14.1" "0.30.4")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

INFECTED_COUNT=0

check_version() {
  local version="$1"
  local path="$2"
  for bad in "${MALICIOUS_VERSIONS[@]}"; do
    if [ "$version" = "$bad" ]; then
      echo -e "    ${RED}⚠️  BETROFFEN: axios@$version${NC} → $path"
      INFECTED_COUNT=$((INFECTED_COUNT + 1))
      return 1
    fi
  done
  echo -e "    ${GREEN}✅ OK:        axios@$version${NC} → $path"
  return 0
}

echo "========================================="
echo "   AXIOS SECURITY SCAN"
echo -e "   ${RED}Suche nach: axios@1.14.1 / axios@0.30.4${NC}"
echo "========================================="

echo ""
echo -e "${BOLD}📦 [1/3] package.json (deklarierte Versionen)${NC}"
echo "-------------------------------------------------"
find / -name "package.json" \
  -not -path "*/node_modules/axios/*" \
  -not -path "*/.git/*" \
  2>/dev/null \
  | while read f; do
    version=$(grep -E '"axios"\s*:\s*"' "$f" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ -n "$version" ]; then
      check_version "$version" "$f"
    fi
  done

echo ""
echo -e "${BOLD}🔒 [2/3] package-lock.json (installierte Versionen)${NC}"
echo "-------------------------------------------------"
find / -name "package-lock.json" \
  -not -path "*/.git/*" \
  2>/dev/null \
  | while read f; do
    versions=$(grep -A2 '"axios"' "$f" 2>/dev/null | grep '"version"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -n "$versions" ]; then
      echo "$versions" | while read version; do
        check_version "$version" "$f"
      done
    fi
  done

echo ""
echo -e "${BOLD}🧶 [3/3] yarn.lock (installierte Versionen)${NC}"
echo "-------------------------------------------------"
find / -name "yarn.lock" \
  -not -path "*/.git/*" \
  2>/dev/null \
  | while read f; do
    versions=$(grep -A1 '^axios@' "$f" 2>/dev/null | grep 'version' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -n "$versions" ]; then
      echo "$versions" | while read version; do
        check_version "$version" "$f"
      done
    fi
  done

echo ""
echo "========================================="
if [ "$INFECTED_COUNT" -gt 0 ]; then
  echo -e "${RED}${BOLD}⚠️  ERGEBNIS: $INFECTED_COUNT BETROFFENE STELLE(N) GEFUNDEN!${NC}"
  echo -e "${YELLOW}   → Sofort updaten: npm install axios@latest${NC}"
else
  echo -e "${GREEN}${BOLD}✅ ERGEBNIS: KEINE BETROFFENEN VERSIONEN GEFUNDEN${NC}"
fi
echo "========================================="
