#!/bin/bash

# Betroffene Versionen
MALICIOUS_VERSIONS=("1.14.1" "0.30.4")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

INFECTED_COUNT=0
TOTAL_FILES=0
SHOW_ALL=false

# Flag prüfen
for arg in "$@"; do
  if [ "$arg" = "--show-all" ]; then
    SHOW_ALL=true
  fi
done

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
  echo -e "    ${GREEN}✅ OK: axios@$version${NC} → $path"
}

scan_file() {
  local f="$1"
  local type="$2"
  TOTAL_FILES=$((TOTAL_FILES + 1))

  local versions=""

  if [ "$type" = "package-lock" ]; then
    versions=$(grep -A3 '"node_modules/axios"' "$f" 2>/dev/null \
      | grep '"version"' \
      | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -z "$versions" ]; then
      versions=$(grep -A2 '"axios"' "$f" 2>/dev/null \
        | grep '"version"' \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    fi

  elif [ "$type" = "yarn" ]; then
    versions=$(grep -A1 '^axios@' "$f" 2>/dev/null \
      | grep 'version' \
      | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

  elif [ "$type" = "package" ]; then
    versions=$(grep -E '"axios"\s*:\s*"' "$f" 2>/dev/null \
      | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
      | head -1)
  fi

  if [ -n "$versions" ]; then
    echo "$versions" | sort -u | while read version; do
      check_version "$version" "$f"
    done
  else
    if [ "$SHOW_ALL" = true ]; then
      echo -e "    ${GREEN}✅ OK: no axios${NC} → $f"
    fi
  fi
}

echo ""
echo -e "${BOLD}=========================================${NC}"
echo -e "${BOLD}        AXIOS SECURITY SCAN              ${NC}"
echo -e "${RED}${BOLD}  Prüfe auf: axios@1.14.1 / axios@0.30.4 ${NC}"
if [ "$SHOW_ALL" = true ]; then
  echo -e "${YELLOW}  Modus: --show-all (zeigt alle Dateien)${NC}"
fi
echo -e "${BOLD}=========================================${NC}"

# ─────────────────────────────────────────
echo ""
echo -e "${BOLD}📦 [1/3] package.json${NC}"
echo "-----------------------------------------"
while IFS= read -r f; do
  scan_file "$f" "package"
done < <(find / \
  -name "package.json" \
  -not -path "*/node_modules/axios/*" \
  -not -path "*/.git/*" \
  2>/dev/null)

# ─────────────────────────────────────────
echo ""
echo -e "${BOLD}🔒 [2/3] package-lock.json${NC}"
echo "-----------------------------------------"
while IFS= read -r f; do
  scan_file "$f" "package-lock"
done < <(find / \
  -name "package-lock.json" \
  -not -path "*/.git/*" \
  2>/dev/null)

# ─────────────────────────────────────────
echo ""
echo -e "${BOLD}🧶 [3/3] yarn.lock${NC}"
echo "-----------------------------------------"
while IFS= read -r f; do
  scan_file "$f" "yarn"
done < <(find / \
  -name "yarn.lock" \
  -not -path "*/.git/*" \
  2>/dev/null)

# ─────────────────────────────────────────
echo ""
echo -e "${BOLD}=========================================${NC}"
echo -e "  Dateien geprüft: ${BOLD}$TOTAL_FILES${NC}"
if [ "$INFECTED_COUNT" -gt 0 ]; then
  echo -e "  ${RED}${BOLD}⚠️  BETROFFEN: $INFECTED_COUNT STELLE(N) GEFUNDEN!${NC}"
  echo ""
  echo -e "  ${YELLOW}Fix im jeweiligen Projektordner:${NC}"
  echo -e "  ${YELLOW}→ npm install axios@latest${NC}"
  echo -e "  ${YELLOW}→ oder: npm install axios@1.7.9${NC}"
else
  echo -e "  ${GREEN}${BOLD}✅ KEINE BETROFFENEN VERSIONEN GEFUNDEN${NC}"
fi
echo -e "${BOLD}=========================================${NC}"
echo ""
