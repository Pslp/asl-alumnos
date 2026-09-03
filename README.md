# Administración de Servicios en Linux — material para el laboratorio

Acá está **lo que baja a tu servidor**: los casos y los escenarios de cada
práctica. Las guías en PDF y la consigna de cada práctica van por el aula
virtual; esto es solo lo que tiene que terminar adentro de la VM.

> **Cátedra:** Administración de Servicios en Linux · UTN FRM · ISI
> **Ciclo lectivo 2026**

## Cómo lo bajás

Tu servidor **no tiene navegador**, y tu notebook **no tiene camino de red hacia
tu propia VM** —el adaptador 1 es NAT y el 2 es la red interna del laboratorio—.
Así que el archivo no se pasa desde afuera: **lo va a buscar el servidor.**

Adentro de `srv1`, con el usuario `sysadmin`:

```bash
cd ~
git clone https://github.com/Pslp/asl-alumnos.git
cd asl-alumnos/pXX
```

Si preferís bajar un archivo suelto en vez de clonar todo:

```bash
curl -fsSLO https://raw.githubusercontent.com/Pslp/asl-alumnos/main/pXX/<archivo>
```

Las dos herramientas —`git` y `curl`— están en la lista de paquetes de la Guía 0,
así que ya las tenés.

## Verificá lo que bajaste, siempre

Cada carpeta trae un `SHA256SUMS`. **Antes de usar nada:**

```bash
sha256sum -c SHA256SUMS
```

Tiene que decir `OK` en cada línea. Si dice `FAILED`, el archivo llegó cortado o
lo tocó alguien: volvé a bajarlo y avisá.

> No es burocracia. Comprobar qué te llegó **antes** de correrlo es exactamente la
> diferencia entre administrar un servidor y tener suerte.

---

## P02 — ¿Qué pasó el fin de semana?

`p02/caso-fds.tar.gz` — los registros del servidor del fin de semana del
incidente. **Son datos, no un programa**: no hay nada que ejecutar.

```bash
sha256sum -c SHA256SUMS
sudo tar -xzf caso-fds.tar.gz -C /
ls -l /srv/caso-fds/
```

Quedan tres archivos en `/srv/caso-fds/`. La consigna está en la guía de la
práctica.

---

## P01 — La plantilla del informe

`p01/p01-informe-plantilla.md` — la copiás a tu bitácora como `p01-informe.md` y
la completás ahí.

```bash
sha256sum -c SHA256SUMS
cp p01-informe-plantilla.md ~/bitacora-<grupo>/p01-informe.md
```

Las secciones 1 y 2 se completan en clase; el análisis y la conclusión, después.
**Cada dato lleva el comando que lo produjo y quién lo ejecutó** — un dato sin
comando no es evidencia.

## P01 — La falla inyectada

`p01/rotura-1.sh`, `rotura-2.sh`, `rotura-3.sh` — **corré solo el número que te
tocó.** Cada uno rompe algo distinto en tu servidor, y el ejercicio es
diagnosticarlo bajando la escalera escalón por escalón.

```bash
sha256sum -c SHA256SUMS
sudo bash rotura-N.sh
```

Si te quedás sin salida, `sudo bash rotura-N.sh restaurar` deja todo como estaba
— pero usarlo antes de encontrar la causa te deja sin el ejercicio, que es lo
único que se corrige.

> **Sí, podés abrir el archivo y leerlo.** El que lo hace se queda sin su
> práctica, y no hay manera de que nos enteremos. Es un acuerdo, no un candado.
