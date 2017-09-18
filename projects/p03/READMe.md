image készítése

```bash
docker build -t y/p03_php .
```

Konténer indítása

```bash
docker run -d --name p03_php -p "8080:80" y/p03_php
```

Konténer indítása volume-mal:

```bash
docker run -d --mount source=p03_php_www,target=/var/www --name p03_php -p "8080:80" y/p03_php
```

[Vissza a főoldalra](../../README.md)