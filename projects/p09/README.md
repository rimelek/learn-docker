# Projekt: p09

A CPU limitet teszteljük ebben a feladatban. A teszthez [petermaric docker.cpu-stress-test] image-ét használjuk.

```bash
docker run -ti -e MAX_CPU_CORES=1 -e STRESS_SYSTEM_FOR=30s --cpus=1 petarmaric/docker.cpu-stress-test
```

A "top" parancs kidásával másik terminálban  megfigyelhető , hogy a "stress" nevű folyamat
100% CPU-t használ. Tehát 1 CPU teljes kapacitását. 

```bash
docker run -ti -e MAX_CPU_CORES=2 -e STRESS_SYSTEM_FOR=30s --cpus=1.5 petarmaric/docker.cpu-stress-test
```
Szintén a "top" paranccsal megfigyelhető, hogy két "stress" folyamat van és mindkettő egy CPU 75%-át használja ki.

```bash
docker run -ti -e MAX_CPU_CORES=1 -e STRESS_SYSTEM_FOR=30s --cpus=0.5 --cpuset-cpus=0 petarmaric/docker.cpu-stress-test
```
A fenti példában kiválasztottuk, hogy a 0 indexű CPU-nak használja csak a felét a teszt.

Az ellenőrzéshez ismét hazsnálható a "top" parancs, viszont az alábbi módon fel kell venni 
a CPU indexeinek oszlopát:

* "top" parancs kiadása
* "f" billentyű leütése
* "P" oszlop kiválasztása nyilakkal
* Kijelölés SPACE billentyűvel 
* "ESC" billentyű megnyomása

[Vissza a főoldalra](../../README.md)