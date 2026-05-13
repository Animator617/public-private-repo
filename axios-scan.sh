#!/bin/bash
echo "========================================="
echo "   AXIOS VERSION SECURITY SCAN"
echo "========================================="

echo ""
echo "📦 [1/3] package.json (deklarierte Versionen)"
echo "-------------------------------------------------"
find / -name "package.json" \
  -not -path "*/node_modules/axios/*" \
  -not -path "*/.git/*" \
  2>/dev/null \
  | xargs grep -H '"axios"' 2>/dev/null \
  | grep -E '"axios"\s*:\s*"' \
  | sed 's/\(.*\):.*"axios"\s*:\s*"\([^"]*\)".*/\1  →  axios: \2/'

echo ""
echo "🔒 [2/3] package-lock.json (tatsächlich installierte Versionen)"
echo "-----------------------------------------------------------------"
find / -name "package-lock.json" \
  -not -path "*/.git/*" \
  2>/dev/null \
  | while read f; do
    matches=$(grep -A2 '"axios"' "$f" 2>/dev/null | grep '"version"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -n "$matches" ]; then
      echo "$f"
      echo "$matches" | while read v; do echo "    → axios@$v"; done
    fi
  done

echo ""
echo "🧶 [3/3] yarn.lock (tatsächlich installierte Versionen)"
echo "---------------------------------------------------------"
find / -name "yarn.lock" \
  -not -path "*/.git/*" \
  2>/dev/null \
  | while read f; do
    matches=$(grep -A1 '^axios@' "$f" 2>/dev/null | grep 'version' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -n "$matches" ]; then
      echo "$f"
      echo "$matches" | while read v; do echo "    → axios@$v"; done
    fi
  done

echo ""
echo "========================================="
echo "   SCAN ABGESCHLOSSEN"
echo "========================================="
