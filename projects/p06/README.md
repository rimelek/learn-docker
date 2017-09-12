Proxy hálózat létrehozása:

```bash
docker network create proxy
```

Ellenőrzés:

```bash
docker network ls
```

Belépés a proxy mappába:

```bash
cd proxy
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