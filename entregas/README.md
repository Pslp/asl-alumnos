# Entregas

Acá cada grupo tiene **su propia carpeta**, y adentro un `README.md` que dice
quiénes son y **dónde está su bitácora**.

Los informes **no se suben acá**: viven en el repositorio de bitácora del grupo,
el que vienen manteniendo desde P01. Esta carpeta es el índice que permite
encontrarlos.

## Cómo armás la de tu grupo

El repositorio es de solo lectura para ustedes, así que el camino es el mismo que
usa cualquiera para proponer un cambio en un proyecto ajeno:

1. **Fork.** Botón *Fork*, arriba a la derecha. Queda una copia tuya en tu cuenta.
2. **Creá tu carpeta** en el fork: `entregas/grupo-NN/`, con un `README.md`
   adentro. Copiá el de [`grupo-00-ejemplo/`](grupo-00-ejemplo/README.md) y
   completalo.
3. **Pull request** hacia este repositorio.

Se puede hacer entero desde el navegador: en tu fork, *Add file → Create new
file*, y escribís `entregas/grupo-NN/README.md` como nombre — GitHub crea la
carpeta sola.

O desde la terminal, si preferís:

```bash
git clone https://github.com/<tu-usuario>/asl-alumnos.git
cd asl-alumnos
mkdir -p entregas/grupo-NN
$EDITOR entregas/grupo-NN/README.md
git add entregas/grupo-NN
git commit -m "grupo NN"
git push
```

Y después el botón *Compare & pull request* que aparece en tu fork.

## Una sola vez

Esto se arma **una vez por grupo**, no una vez por práctica. Cuando entregan una
práctica nueva, commitean en **su** bitácora: acá no hay que tocar nada.

## Qué no va

Este repositorio es **público**. En el `README.md` del grupo no pongan legajos,
correos, teléfonos ni nada que no quieran que lea cualquiera.
