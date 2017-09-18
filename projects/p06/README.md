Proxy hálózat létrehozása:

```bash
docker network create public_proxy
```

Ellenőrzés:

```bash
docker network ls
```

Belépés az nginxproxy mappába:

```bash
cd nginxproxy
```

Proxy indítása:

```bash
docker-compose up -d
```

Átlépés a web1 mappába:

```bash
cd ../web1
```

web1 indítása:

```bash
docker-compose up -d
```

Átlépés a web2 mappába:

```bash
docker-compose up -d
```

Mindkét szolgáltatás elérhető a 80-as porton:

```text
http://web1.193.x.x.x.xip.io
http://web2.193.x.x.x.xip.io
```

[Vissza a főoldalra](../../README.md)