# Projekt: p08

## Leírás

A példa a memórialimit tesztelését mutatja be egy php konténerben, ahol a "truncate"
parancs generál egy megadott méretű fájlt, majd a php azt beolvassa a memóriába.
A méretet környezeti változóból adjuk át a docker-compose.yml fájlnak.

## Teszt indítása

A konténer 50MB memórialimitet kap. (minimum 4MB állíthat be). 
Az alábbi példák fokozatosan növelt memóriahasználatot tesztelnek:

```bash
MEMSIZE=10MB docker-compose run --rm php
MEMSIZE=20MB docker-compose run --rm php
MEMSIZE=30MB docker-compose run --rm php
MEMSIZE=40MB docker-compose run --rm php
MEMSIZE=50MB docker-compose run --rm php
# bash: line 1:  8 Killed   php -r ' ob_start(); readfile("/tmp/50MB"); ob_clean(); echo (memory_get_peak_usage(true)/1024/1024)." MiB\n"; '
```

A "Killed" jelzi, hogy meghaladtuk a limitet. 40MB memóriahasználat mellett
még nincs hibaüzenet. 50MB-ot meghaladva már igen. A fenti memóriateszt nem ad 100%-osan 
pontos eredményt, de 50MB környékén következik be a hibaüzenet.

## Paraméterek magyarázata

A Docker Compose "run" utasítása egy kiválasztott szolgáltatást indít el a docker-compose.yml fájlból
hasonlóan, mint a "docker run". Így a "--rm" jelentése is azonos. A lefutás után
a konténer törlődik.

[Vissza a főoldalra](../../README.md)