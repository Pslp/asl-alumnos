#!/usr/bin/env bash
# Escenario de diagnóstico — P03.
#
# Se ejecuta en TU servidor, como root:
#
#   sudo bash rotura.sh
#
# Elige al azar una de tres fallas y la aplica. A partir de ahí el healthcheck
# deja de correr solo, pero el script sigue andando perfecto si lo ejecutás vos
# a mano: esa es la gracia.
#
# No mires este archivo para averiguar qué te tocó. Averigualo con la máquina:
# ¿corrió la tarea? · si corrió, ¿qué dijo? · si anda a mano y no automatizado,
# ¿qué es distinto?
#
# Para dejar todo como estaba:
#
#   sudo bash rotura.sh restaurar
#
# Guarda el estado previo en /root/p03-rotura/ y nunca toca el log ni el
# contenido del script: restaurar devuelve todo exactamente como estaba.
set -euo pipefail

BK=/root/p03-rotura
SCRIPT=/usr/local/bin/healthcheck.sh
CRON=/etc/cron.d/healthcheck

mkdir -p "$BK"

respaldar() {
  [ -f "$BK/cron.previo" ] || cp -a "$CRON" "$BK/cron.previo"
  [ -f "$BK/modo.previo" ] || stat -c '%a' "$SCRIPT" > "$BK/modo.previo"
}

exigir_instalado() {
  if [ ! -f "$SCRIPT" ] || [ ! -f "$CRON" ]; then
    echo "falta el healthcheck instalado ($SCRIPT y $CRON)" >&2
    echo "terminá el punto 4 de la práctica antes de correr esto" >&2
    exit 1
  fi
}

exigir_sin_aplicar() {
  if [ -f "$BK/variante" ]; then
    echo "ya hay una falla aplicada. Diagnosticala, o corré: $0 restaurar" >&2
    exit 1
  fi
}

caso_a() {
  respaldar
  cat > "$CRON" <<'FIN'
# healthcheck cada 5 minutos — P03
*/5 * * * * root healthcheck.sh
FIN
  chmod 644 "$CRON"
  echo "a" > "$BK/variante"
}

caso_b() {
  respaldar
  chmod 644 "$SCRIPT"
  echo "b" > "$BK/variante"
}

caso_c() {
  respaldar
  cat > "$CRON" <<'FIN'
# healthcheck cada 5 minutos — P03
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
*/5 * * * * /usr/local/bin/healthcheck.sh
FIN
  chmod 644 "$CRON"
  echo "c" > "$BK/variante"
}

# Sortea cuál aplicar. Que sea al azar y no asignado es a propósito: nadie
# —ni vos— sabe qué le tocó hasta diagnosticarlo, así que preguntarle al de al
# lado no sirve de nada.
aplicar() {
  local variantes=(a b c)
  local elegida="${variantes[RANDOM % ${#variantes[@]}]}"
  "caso_$elegida"
  echo "Listo. El healthcheck dejó de correr solo."
  echo "Averiguá por qué: el script a mano sigue andando."
}

restaurar() {
  if [ -f "$BK/cron.previo" ]; then
    cp -a "$BK/cron.previo" "$CRON"
    rm -f "$BK/cron.previo"
  fi
  if [ -f "$BK/modo.previo" ]; then
    chmod "$(cat "$BK/modo.previo")" "$SCRIPT"
    rm -f "$BK/modo.previo"
  fi
  rm -f "$BK/variante"
  echo "Estado restaurado. Verificá: $SCRIPT ; echo \$? ; cat $CRON"
}

case "${1:-aplicar}" in
  aplicar)   exigir_instalado; exigir_sin_aplicar; aplicar ;;
  a|b|c)     exigir_instalado; "caso_$1" ;;
  restaurar) restaurar ;;
  *) echo "Uso: $0 [aplicar|restaurar]" >&2; exit 1 ;;
esac
