Image készítése:

```bash
docker build -t y/p02_httpd .
```
A fenti utasításban figyelni kell a végén a pontra.

Konténer indítása

```bash
docker run -d --name p02_httpd -p "80:80" y/p02_httpd
```

Böngészőből 80-as porton megnyitható. Kiírja, hogy "Hello Docker (p02)"

[Vissza a főoldalra](../../README.md)
