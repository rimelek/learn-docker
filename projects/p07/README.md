# Projekt: P07

## Leírás

A példa előfeltétele a [p06-os projekt-ben](../p06/README.md) az nginx-proxy elindítása.

Szükség esetén villámgyorsan elindítható egy webszerver HTTP autentikációval,
amihez a nevet és jelszót változóban adjuk át. Hosszú távon érdemesebb biztonságosabb módon
létrehozni előre a ".htpasswd" fájlt.

A htpasswd fájlt automatikusan hozza létre egy konténer, ami ezután le is áll.

A [.env](https://github.com/itsziget/learn-docker/tree/master/projects/p07/.env) fájlban
a HTTPD_USER és HTTPD_PASS változókat kell megadni, amit a [docker-compose.yml](https://github.com/itsziget/learn-docker/tree/master/projects/p07/) fájlban
a "htpasswd" szolgáltatás használ fel a jelszófájl generálásához, amit a "httpd"
szolgáltatással közös volume-on keresztül oszt meg.


A "fixperm" szolgáltatás a "htpasswd"-hez hasonlóan csak elvégzo a dolgát, majd leáll.
Az a dolga, hogy a szerver elindulása után beállítsa megfelelően a fájlok és mappák jogait.

A szolgáltatások indulásának sorrendjét a "depends_on" opcióval lehet szabályozni.

## Webszerver indítása

```bash
docker-compose up -d
```

Ezután a böngészőben a p07.X.X.X.X.xip.io webcímen már jelszót kér a böngésző.