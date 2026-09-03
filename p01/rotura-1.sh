#!/usr/bin/env bash
# Escenario de diagnóstico — P01.
#
# Se ejecuta en TU servidor (srv1), como root:
#
#   sudo bash rotura-1.sh
#
# A partir de ahí el servidor tiene una falla. Bajá la escalera de diagnóstico
# escalón por escalón y anotá: síntoma → escalón donde apareció la evidencia →
# causa → cómo lo arreglaste.
#
# Si te quedás sin salida, esto deja todo como estaba:
#
#   sudo bash rotura-1.sh restaurar
#
# (pero usarlo antes de encontrar la causa te deja sin el ejercicio, que es lo
#  único que se corrige).
#
# Generado automáticamente — no editar a mano.
set -euo pipefail

BK=/root/p01-rotura
mkdir -p "$BK"

aplicar() {
  systemctl stop ssh
}
restaurar() {
  systemctl start ssh 2>/dev/null || true
}

case "${1:-aplicar}" in
  aplicar) aplicar ;;
  restaurar) restaurar ;;
  *) echo "Uso: $0 [aplicar|restaurar]" >&2; exit 1 ;;
esac
