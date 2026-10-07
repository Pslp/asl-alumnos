#!/usr/bin/env bash
# Escenario de recuperación — P05.
#
# Se ejecuta en TU servidor, como root:
#
#   sudo bash intervencion.sh
#
# Simula una intervención que se llevó puesto el chequeo automático. Hace dos
# cosas:
#
#   1. Borra el contenido de /backup — el respaldo que dejaste en la propia
#      máquina. Eso le pasa a todo el mundo, y no es un acertijo: es la
#      demostración de por qué el punto 3 te hizo copiarlo a cli1.
#
#   2. Se lleva UNA de las tres partes del servicio, elegida al azar. Ahí sí no
#      todos pierden lo mismo:
#
#        el programa       -> la tarea corre y falla
#        la configuración  -> no corre nada, y el silencio se parece a "todo bien"
#        el registro       -> todo funciona, y el histórico se perdió
#
# No mires este archivo para averiguar qué te tocó. Averigualo con la máquina:
# ¿qué dice el respaldo que tenía que haber? · ¿qué hay ahora? · ¿la diferencia
# explica lo que ves?
#
# Salida de emergencia, si te quedaste sin respaldo y sin ejercicio:
#
#   sudo bash intervencion.sh rescate
#
# Usarla es renunciar a la práctica, que es lo único que se corrige. Guarda una
# copia en /root/p05-intervencion/ para que nadie pierda su máquina de verdad.
set -euo pipefail

BK=/root/p05-intervencion
SCRIPT=/usr/local/bin/healthcheck.sh
CRON=/etc/cron.d/healthcheck
LOG=/var/log/healthcheck.log
RESPALDOS=/backup

mkdir -p "$BK"

exigir_instalado() {
  local faltan=()
  [ -f "$SCRIPT" ] || faltan+=("$SCRIPT")
  [ -f "$CRON" ]   || faltan+=("$CRON")
  [ -f "$LOG" ]    || faltan+=("$LOG")
  if [ ${#faltan[@]} -gt 0 ]; then
    echo "falta parte del chequeo automático de P03:" >&2
    printf '  %s\n' "${faltan[@]}" >&2
    echo "no hay nada que recuperar todavía. Restaurá el checkpoint y volvé a intentar." >&2
    exit 1
  fi
}

exigir_sin_aplicar() {
  if [ -f "$BK/parte" ]; then
    echo "ya hay una intervención aplicada. Recuperala, o corré: $0 rescate" >&2
    exit 1
  fi
}

respaldar_todo() {
  cp -a "$SCRIPT" "$BK/healthcheck.sh"
  cp -a "$CRON"   "$BK/cron-healthcheck"
  cp -a "$LOG"    "$BK/healthcheck.log"
}

vaciar_backup_local() {
  # Solo el contenido: el punto de montaje y el volumen quedan como estaban.
  # lost+found se respeta: lo crea el sistema de archivos, no el alumno, y
  # borrarlo solo genera una pregunta que no lleva a ningún lado.
  [ -d "$RESPALDOS" ] || return 0
  find "$RESPALDOS" -mindepth 1 -maxdepth 1 ! -name 'lost+found' -exec rm -rf {} + 2>/dev/null || true
}

caso_programa()      { rm -f "$SCRIPT"; echo programa      > "$BK/parte"; }
caso_configuracion() { rm -f "$CRON";   echo configuracion > "$BK/parte"; }
caso_registro()      { rm -f "$LOG";    echo registro      > "$BK/parte"; }

intervenir() {
  # El orden importa: si ya hay una intervención aplicada, por definición FALTA
  # una de las tres partes. Si exigir_instalado corriera primero, el alumno que
  # ejecuta el script dos veces leería "falta parte del chequeo, restaurá el
  # checkpoint" — y restauraría un checkpoint, perdiendo su trabajo, cuando lo
  # único que pasó es que lo corrió de nuevo.
  exigir_sin_aplicar
  exigir_instalado
  respaldar_todo
  vaciar_backup_local
  local partes=(programa configuracion registro)
  local elegida="${partes[RANDOM % ${#partes[@]}]}"
  "caso_$elegida"
  echo "Listo. Alguien pasó por este servidor."
  echo
  echo "El chequeo automático ya no es lo que era, y /backup quedó vacío."
  echo "Averiguá qué falta comparando contra tu respaldo — el que sacaste de acá."
}

rescate() {
  if [ ! -f "$BK/parte" ]; then
    echo "no hay ninguna intervención aplicada." >&2
    exit 1
  fi
  [ -f "$BK/healthcheck.sh"    ] && cp -a "$BK/healthcheck.sh"    "$SCRIPT"
  [ -f "$BK/cron-healthcheck"  ] && cp -a "$BK/cron-healthcheck"  "$CRON"
  [ -f "$BK/healthcheck.log"   ] && cp -a "$BK/healthcheck.log"   "$LOG"
  rm -f "$BK/parte"
  echo "Rescate hecho: el chequeo volvió a estar completo."
  echo "El contenido de /backup NO se devuelve: ese lo tenías que tener afuera."
}

case "${1:-intervenir}" in
  intervenir)     intervenir ;;
  rescate)        rescate ;;
  programa)       exigir_sin_aplicar; exigir_instalado; respaldar_todo; vaciar_backup_local; caso_programa ;;
  configuracion)  exigir_sin_aplicar; exigir_instalado; respaldar_todo; vaciar_backup_local; caso_configuracion ;;
  registro)       exigir_sin_aplicar; exigir_instalado; respaldar_todo; vaciar_backup_local; caso_registro ;;
  *) echo "Uso: $0 [programa|configuracion|registro|rescate]  (sin argumento: sortea)" >&2; exit 1 ;;
esac
