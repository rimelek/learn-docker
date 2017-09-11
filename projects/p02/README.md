Image készítése:

```bash
docker build -t y/p02_httpd
```

Konténer indítása

```bash
docker run -d --name p02_httpd -p "80:80" y/p02_httpd
```

Böngészőből 80-as porton megnyitható. Kiírja, hogy "Hello Docker (p02)"
