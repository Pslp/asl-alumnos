#!/usr/bin/env bash
# Escenario de diagnóstico — P01.
#
# Se ejecuta en TU servidor (srv1), como root:
#
#   sudo bash rotura-3.sh
#
# A partir de ahí el servidor tiene una falla. Bajá la escalera de diagnóstico
# escalón por escalón y anotá: síntoma → escalón donde apareció la evidencia →
# causa → cómo lo arreglaste.
#
# Si te quedás sin salida, esto deja todo como estaba:
#
#   sudo bash rotura-3.sh restaurar
#
# (pero usarlo antes de encontrar la causa te deja sin el ejercicio, que es lo
#  único que se corrige).
#
# Generado automáticamente — no editar a mano.
set -euo pipefail

BK=/root/p01-rotura
mkdir -p "$BK"

CFG=/etc/ssh/sshd_config
MARCA="# p01-escenario"
aplicar() {
  cp -a "$CFG" "$BK/sshd_config.previo"
  printf '%s\nAllowUsers nadie_existe %s\n' "$MARCA" "$MARCA" >> "$CFG"
  sshd -t                      # si la config quedara inválida, abortamos acá
  systemctl restart ssh
}
restaurar() {
  [ -f "$BK/sshd_config.previo" ] || return 0
  cp -a "$BK/sshd_config.previo" "$CFG"
  sshd -t && systemctl restart ssh
  rm -f "$BK/sshd_config.previo"
}

case "${1:-aplicar}" in
  aplicar) aplicar ;;
  restaurar) restaurar ;;
  *) echo "Uso: $0 [aplicar|restaurar]" >&2; exit 1 ;;
esac
