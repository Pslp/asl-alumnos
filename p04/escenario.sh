#!/usr/bin/env bash
# Escenario P04 — "el servidor está lento". Genera UNA saturación real, con un
# perfil distinto por alumno, para que el diagnóstico ajeno no sirva.
#
# motor: vbox
# paquetes: procps sysstat
#
# ⚠ SOLO EN VM. En un contenedor, `uptime`, `vmstat` e `iostat` miden al
#   anfitrión, no a la caja: el diagnóstico daría números de otra máquina.
#
# Uso (como root, en srv1):
#   escenario-p04.sh            SORTEA una de las tres y la aplica  ← lo del alumno
#   escenario-p04.sh cpu        el CPU se satura
#   escenario-p04.sh memoria    la memoria se consume
#   escenario-p04.sh io         el disco no da abasto
#   escenario-p04.sh limpiar    detiene todo y borra los rastros
#
# Sin argumento sortea, igual que `p03-rotura.sh`. Es lo que hace que la causa sea
# POR INTEGRANTE y no por mesa: cada uno corre el mismo archivo y a cada uno le
# toca otra cosa. Nadie —tampoco el docente— sabe qué le tocó a quién hasta que lo
# diagnostica, así que preguntarle al de al lado no sirve.
#
# El perfil sorteado queda en $CORRIENDO/perfil, para que `limpiar` y el
# verificador sepan qué se aplicó. El alumno PUEDE leerlo: si quiere arruinarse la
# práctica mirando un archivo, es su práctica. Lo que no puede es deducirlo del
# nombre del script, que era el problema real.
#
# Los tres perfiles instalan además la MISMA pista falsa: un proceso con nombre
# alarmante que no consume nada. Quien diagnostique por el nombre del proceso en
# vez de por la medición, se equivoca — y esa es la mitad de la clase.
#
# Todo lo que lanza es matable con kill: la intervención del alumno tiene que
# funcionar de verdad.
set -euo pipefail

DIR=/usr/local/bin
CORRIENDO=/run/p04-escenario
mkdir -p "$CORRIENDO"

# ── la pista falsa ─────────────────────────────────────────────────────────
instalar_pista_falsa() {
  cat > "$DIR/monitor-seguridad.sh" <<'FIN'
#!/bin/bash
# Parece el sospechoso ideal: nombre alarmante, corre hace horas, es del root.
# No hace absolutamente nada. Está para castigar el diagnóstico por corazonada.
while true; do sleep 300; done
FIN
  chmod 755 "$DIR/monitor-seguridad.sh"
  nohup "$DIR/monitor-seguridad.sh" >/dev/null 2>&1 &
  echo $! > "$CORRIENDO/pista-falsa.pid"
}

# ── perfil cpu ─────────────────────────────────────────────────────────────
perfil_cpu() {
  cat > "$DIR/generador-informes.sh" <<'FIN'
#!/bin/bash
# "Generador de informes mensuales." Quema un núcleo entero, para siempre.
sha256sum /dev/zero >/dev/null
FIN
  chmod 755 "$DIR/generador-informes.sh"
  nohup "$DIR/generador-informes.sh" >/dev/null 2>&1 &
  echo $! > "$CORRIENDO/carga.pid"
  echo cpu > "$CORRIENDO/perfil"
  echo "Perfil CPU: generador-informes.sh consumiendo un núcleo."
}

# ── perfil memoria ─────────────────────────────────────────────────────────
perfil_memoria() {
  # 18% de la RAM total, con techo y piso, y los tres números salen de medir en
  # srv1 (2 GB), no de estimar. Dos correcciones que costaron una corrida:
  #
  # 1. Bash NO usa el doble mientras arma la variable: usa como TRES veces lo
  #    pedido. Con 35% (688 MB) el pico fue de 1816 MB sobre 1967 de RAM — se
  #    comió el swap entero y estuvo al borde del OOM killer.
  # 2. Peor: después de ese pico el proceso se iba ENTERO a swap y su RSS caía a
  #    1 MB. A los quince segundos la máquina se veía sana otra vez y el alumno
  #    que midiera después no encontraba nada. La causa era el `sleep 30`: el
  #    dato se tocaba tan poco que el kernel se lo llevaba.
  #
  # Con 18% y tocando cada 2 s, medido en srv1: el proceso queda residente y la
  # memoria disponible cae de 1723 a 683 MB, que es lo que el alumno tiene que
  # ver contra su foto del antes.
  local kb mb
  kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
  mb=$(( kb * 18 / 100 / 1024 ))
  [ "$mb" -lt 120 ] && mb=120
  [ "$mb" -gt 400 ] && mb=400
  cat > "$DIR/indexador-catalogo.sh" <<FIN
#!/bin/bash
# "Indexador del catálogo." Reserva $mb MB y se queda con ellos.
datos=\$(head -c ${mb}M /dev/zero | tr '\\0' 'x')
while true; do
  echo -n "\${datos:0:1}" > /dev/null   # tocar el dato para que no se lo lleve el swap
  sleep 2
done
FIN
  chmod 755 "$DIR/indexador-catalogo.sh"
  nohup "$DIR/indexador-catalogo.sh" >/dev/null 2>&1 &
  echo $! > "$CORRIENDO/carga.pid"
  echo memoria > "$CORRIENDO/perfil"
  echo "Perfil memoria: indexador-catalogo.sh reservando ${mb} MB."
}

# ── perfil io ──────────────────────────────────────────────────────────────
perfil_io() {
  cat > "$DIR/sincronizador-respaldos.sh" <<'FIN'
#!/bin/bash
# "Sincronizador de respaldos." Escribe y sincroniza a disco sin parar.
# Usa poco CPU: en top casi no se ve. Ese es el punto.
#
# `oflag=dsync` es lo que hace que funcione, y costó descubrirlo. Con bloques
# grandes y un solo fsync al final —como estaba antes— escribir 120 MB tarda
# 0,14 s en un disco moderno: el perfil dormía más de lo que escribía y la espera
# de disco no llegaba al 7%. Con dsync cada bloque de 4k espera a que el
# dispositivo confirme, así que la cola no se vacía nunca. Medido en srv1: 98% de
# espera con el CPU al 2%, que es exactamente la lección.
while true; do
  dd if=/dev/zero of=/var/tmp/.sync-parcial bs=4k count=3000 oflag=dsync status=none
  rm -f /var/tmp/.sync-parcial
done
FIN
  chmod 755 "$DIR/sincronizador-respaldos.sh"
  nohup "$DIR/sincronizador-respaldos.sh" >/dev/null 2>&1 &
  echo $! > "$CORRIENDO/carga.pid"
  echo io > "$CORRIENDO/perfil"
  echo "Perfil IO: sincronizador-respaldos.sh saturando el disco."
}

# ── limpieza ───────────────────────────────────────────────────────────────
limpiar() {
  local pid archivo
  for archivo in "$CORRIENDO"/*.pid; do
    [ -e "$archivo" ] || continue
    pid=$(cat "$archivo")
    kill "$pid" 2>/dev/null || true
    sleep 1
    kill -9 "$pid" 2>/dev/null || true
    rm -f "$archivo"
  done
  # por si el alumno mató el padre y quedó el hijo dando vueltas.
  # Tiene que ser `-f` y no el nombre a secas: el kernel trunca el nombre de
  # proceso a 15 caracteres, así que `monitor-seguridad.sh` figura como
  # `monitor-segurid` y un pkill por nombre exacto no lo encuentra nunca.
  # El costo de `-f` es que también mataría un proceso ajeno que mencione estos
  # nombres en su línea de comandos; en la VM del alumno eso no pasa.
  pkill -f 'generador-informes.sh|indexador-catalogo.sh|sincronizador-respaldos.sh|monitor-seguridad.sh' 2>/dev/null || true
  pkill -f 'sha256sum /dev/zero' 2>/dev/null || true
  rm -f "$DIR"/{generador-informes.sh,indexador-catalogo.sh,sincronizador-respaldos.sh,monitor-seguridad.sh}
  rm -f /var/tmp/.sync-parcial "$CORRIENDO/perfil"
  echo "Escenario P04 limpio."
}

# ── el sorteo ──────────────────────────────────────────────────────────────
sortear() {
  if [ -f "$CORRIENDO/perfil" ]; then
    echo "ya hay un escenario aplicado. Diagnosticalo, o corré: $0 limpiar" >&2
    exit 1
  fi
  local perfiles=(cpu memoria io)
  local elegido="${perfiles[RANDOM % ${#perfiles[@]}]}"
  limpiar >/dev/null
  instalar_pista_falsa
  "perfil_$elegido" >/dev/null
  echo "Listo. Tu servidor está lento."
  echo "Averiguá por qué: medí, no adivines. Y no acuses por el nombre de un proceso."
}

case "${1:-sortear}" in
  sortear)  sortear ;;
  cpu)      limpiar >/dev/null; instalar_pista_falsa; perfil_cpu ;;
  memoria)  limpiar >/dev/null; instalar_pista_falsa; perfil_memoria ;;
  io)       limpiar >/dev/null; instalar_pista_falsa; perfil_io ;;
  limpiar)  limpiar ;;
  *) echo "Uso: $0 [cpu|memoria|io|limpiar]  (sin argumento: sortea)" >&2; exit 1 ;;
esac
