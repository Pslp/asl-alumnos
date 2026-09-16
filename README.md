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

**Si ya lo clonaste en una práctica anterior, no vuelvas a clonar: actualizalo.**
Cada práctica nueva agrega una carpeta, y sin esto no la vas a ver:

```bash
cd ~/asl-alumnos
git pull
```

Si `git pull` se queja de cambios locales, es porque ejecutaste algo que dejó
rastro adentro de la carpeta. Lo más simple es descartar esos cambios —el material
es de solo lectura, no perdés nada tuyo— con `git checkout -- .` y volver a
intentar.

Y si `git pull` dice que **necesita saber cómo reconciliar ramas divergentes**, es
otro problema: tu copia quedó desalineada de una manera que un `pull` no puede
resolver. No pierdas tiempo peleándola —acá no hay nada tuyo que salvar—, borrala
y volvé a clonar:

```bash
cd ~ && rm -rf asl-alumnos
git clone https://github.com/Pslp/asl-alumnos.git
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

## P04 — El servidor está lento

`p04/escenario.sh` — **elige al azar una de tres causas de lentitud** y la aplica
a tu servidor. A cada uno le toca una distinta, así que el diagnóstico del de al
lado no te sirve.

**Antes de correrlo, tomá la foto del antes** (punto 1 de la práctica): con la
máquina todavía sana, anotá tus números con la hora. Esa medición no se puede
recuperar después, y sin ella no vas a tener con qué comparar.

```bash
cd ~/asl-alumnos
git pull
cd p04
sha256sum -c SHA256SUMS
sudo bash escenario.sh
```

De ahí en adelante el método es medir, no adivinar: **¿qué recurso está
saturado?** · **¿qué otra herramienta dice lo mismo?** · **¿desde cuándo corre ese
proceso?**

> **No se acusa por el nombre de un proceso. Se acusa por el número.**

**Antes de irte de la clase**, dejá la máquina como estaba:

```bash
sudo bash escenario.sh limpiar
```

No es opcional: si te vas con la carga puesta, la próxima vez que enciendas la VM
va a arrancar de rodillas y no vas a saber por qué.

> **Nadie sabe qué te tocó, ni el docente**: el script sortea. Como en P03, podés
> abrir el archivo y leerlo — y como en P03, el que lo hace se queda sin su
> práctica.

---

## P03 — La falla inyectada

`p03/rotura.sh` — **elige al azar una de tres fallas** y la aplica a tu servidor.
El healthcheck deja de correr solo, pero el script sigue andando perfecto si lo
ejecutás vos a mano: ahí está el ejercicio.

**Corrélo recién cuando tengas el punto 4 de la práctica terminado**, con el
healthcheck instalado y la tarea de cron andando. Si no, no hay nada que romper y
el script te lo va a decir.

```bash
cd ~/asl-alumnos
git pull
cd p03
sha256sum -c SHA256SUMS
sudo bash rotura.sh
```

A partir de ahí, el método es el de siempre: **¿corrió la tarea?** · si corrió,
**¿qué dijo?** · si anda a mano y no automatizado, **¿qué es distinto?**

Para dejar todo como estaba:

```bash
sudo bash rotura.sh restaurar
```

> **Nadie sabe qué te tocó, ni el docente**: el script sortea. Preguntarle al de al
> lado no sirve, porque el de al lado tampoco sabe cuál le tocó a él hasta
> diagnosticarla. **Averiguar cuál es te la pasa la práctica**, y por eso el
> informe pide nombrarla.

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
