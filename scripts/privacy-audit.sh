#!/usr/bin/env bash
# privacy-audit.sh — Batería anti-fuga de datos sensibles (Sportbar-Public)
#
# Gate de privacidad: cero coincidencias o el check falla.
# Corre en: GitHub Action (Sportbar-Public) + gate manual del mirror (repo privado).
#
# Patrones PROHIBIDOS (cualquier coincidencia = fuga):
#   - IPs LAN: 192.168.x.x y 10.8.x.x
#   - OUI/MACs reales de hardware: 341B22, 6C9308 (y cualquier MAC con colones)
#   - MACs placeholder con formato antiguo (por si un mirror arrastra un placeholder mal)
#   - Hostnames de workstation: DESKTOP-XXXXXXX
#   - Documento de inventario interno
#   - Contactos corporativos != soporte@
#
# EXCEPCIONES (decisión del dueño del repo, 2026-09-24):
#   - Branding del venue (palermo/hipodromo, logo): SOLO en src/componentes/Header.jsx,
#     src/componentes/Header.module.css y public/logos/ (es la app del cliente)
#   - Placeholder AA000000000x en src/contexto/dispositivos.js y src/data/zonasFuera.js
#
# Uso: ./privacy-audit.sh [raiz-del-repo]   (default: cwd)

set -uo pipefail
ROOT="${1:-.}"
cd "$ROOT" || exit 1

FAIL=0
HITS=""

check() { # check <descripcion> <comando-grep...>
  local label="$1"; shift
  local out
  out=$(git grep -I -n -E "$1" -- . 2>/dev/null)
  if [ -n "$out" ]; then
    FAIL=1
    HITS+="--- $label ---"$'\n'"$out"$'\n'
  fi
}

echo "== privacy-audit: escaneando arbol tracked de $ROOT =="

# 1) IPs de red interna (v4)
check "IP LAN 192.168.x.x"        "192\.168\.[0-9]+\.[0-9]+"
check "IP LAN 10.8.x.x"           "10\.8\.[0-9]+\.[0-9]+"

# 2) OUIs reales de hardware + MACs con colones (formato AA:BB:CC:...)
check "OUI 341B22 / 6C9308"       "341B22|6C9308"
check "MACs con colones"          "\b[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}\b"

# 3) Hostnames / docs internos
check "hostnames DESKTOP-"        "DESKTOP-[A-Z0-9]+"
check "referencia-instalacion"    "referencia-instalacion"

# 3-b) Contactos @wetechar.com que NO sean soporte@ (excepción intencional).
#      NO filtrar por línea completa: una línea que contenga soporte@ + otro
#      contacto ocultaría el contacto prohibido. Se remueve SOLO el match
#      permitido y lo que queda es fuga.
CONTACT_HITS=$(git grep -I -n -E "[a-z0-9._-]+@wetechar\.com" -- . 2>/dev/null \
  | sed 's/soporte@wetechar\.com//g' \
  | grep -E "@wetechar\.com" || true)
if [ -n "$CONTACT_HITS" ]; then
  FAIL=1
  HITS+="--- contactos @wetechar != soporte@ ---"$'\n'"$CONTACT_HITS"$'\n'
fi

# 3) Archivos/directorios que NUNCA deben existir en el espejo publico
for banned in "AGENTS.md" "wiki" "Docs" "openspec" "API commands" ".obsidian" "log.md" "index.md"; do
  if [ -e "$ROOT/$banned" ]; then
    FAIL=1
    HITS+="--- archivo/directorio excluido presente: $banned ---"$'\n'
  fi
done

# 4) MACs hexadecimales de 12 dígitos en archivos de data/contexto que NO sean
#    el placeholder AA000000000x ni códigos IR Pronto HEX (strings de 40+ chars,
#    códigos universales de control remoto, no identificadores de red).
MAC_HITS=$(git grep -I -n -E "\b[0-9A-Fa-f]{12}\b" -- "src/contexto" "src/data" 2>/dev/null \
  | grep -v "AA00000000" \
  | grep -vE ":.{0,200}'[0-9A-Fa-f]{40,}'" || true)
if [ -n "$MAC_HITS" ]; then
  FAIL=1
  HITS+="--- MACs hex (12 dígitos) no-placeholder en data/contexto ---"$'\n'"$MAC_HITS"$'\n'
fi

if [ -n "$HITS" ]; then
  echo ""
  echo "❌ PRIVACY GATE: FALLO — coincidencias sensibles detectadas:"
  echo "$HITS"
  echo ""
  echo "NO pushear. Corregir con las sanitizaciones de la convencion (AGENTS.md del repo privado)."
  exit 1
fi

echo "✅ privacy-audit: cero coincidencias sensibles en el arbol ($(git ls-files | wc -l) archivos trakeados)."
exit 0
