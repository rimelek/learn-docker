Konténer indítása ás image készítése

```bash
docker-compose up -d
```

Konténer ellenőrzése:

```bash
docker ps -f ancestor=y/p04_php
# A konténer neve: p04_php_1
```

Hálózatok ellenőrzése:

```bash
docker network ls
# Új bridge típusú hálózat: p04_default
```