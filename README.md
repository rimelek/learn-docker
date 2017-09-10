# Utasítások

## Információ a rendszerről

```bash
docker help
docker info
docker version
docker --version
```

## Előrecsomagolt alkalmazás tesztelése

```bash
docker run --rm -p "8080:80" rimelek/phar-examples:1.0
```

## Demo "hello-world" image

Konténer indítása:

```bash
docker run hello-world
# vagy
docker container run hello-world
```
A hello-world kimenete

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
```     

A futó konténerek listázása

```bash
docker ps
# vagy
docker container ls
# vagy 
docker container list
```

Az összes konténer listázása

```bash
docker ps -a
```
Csak a hello-world image-ből indított konténerek listázása

```bash
docker ps -a -f ancestor=hello-world
# vagy
docker container list --all --filter ancestor=hello-world
```

Leállított konténer törlése

```bash
docker rm konténernév
# vagy
docker container rm konténernév
# vagy
docker container remove konténernév
```

Futó konténer esetén:
```bash
docker rm -f konténernév
```

Ha a konténer generált neve "angry_shaw"

```bash
docker rm angry_shaw
```

Konténer indítása névvel:

```bash
docker run --name hello hello-world
```

Újra lefuttatva a fenti utasítást hibaüzenetet kapunk, mert "hello" néven már létezik konténer.
Az alábbi paranccsal ellenőrizhető:

```bash
docker ps -a
```

Viszont már a megadott néven lehet rá hivatkozni és újra elindítani:

```bash
docker start hello
```

A fenti parancs csak kiírja a konténer nevét. "attached" módban kell indítani:

```bash
docker start -a hello
```

A "hello" konténer törlése

```bash
docker rm hello
```

Konténer automatikus törlése leállítás után

```bash
docker run --rm hello-world
```

## Apache HTTPD webszerver

Szerver indítása előtérben ("attached" módban)

```bash
docker run --name web httpd:2.4
```

Nem kapunk vissza promptot. "CTRL+C" billentyűkombinációval leállítható a szerver.

Háttérben indítás:

```bash
docker run -d --name web httpd:2.4
```
Ezután a "docker ps" utasítással már látható a futó konténer.

A háttérben futó "web" konténer kimenetének ellenőrzése

```bash
docker logs web
# vagy 
docker container logs web
```

A kimenet (logok) folyamatos figyelése

```bash
docker logs -f web
```

Tesztelhető wget-tel, hogy működik a szerver:

```bash
wget -qO- 172.17.0.2
```
Kimenet:
```html
<html><body><h1>It works!</h1></body></html>
```

"web" konténer törlése és elindítás a hoszt portjának átirányításával

```bash
docker rm -f web
docker run -d -p "8080:80" --name web httpd:2.4
```

## Munka a konténer fájlrendszerével saját image nélkül

Parancs futtatása a futó "web" konténerben

```bash
docker exec -it web ls -la
```

"Belépés" a konténerbe

```bash
docker exec -it web bash
```

"Belépés" a konténerbe nsenter-rel (régen):

```bash
sudo nsenter -t $(docker inspect --format '{{ .State.Pid }}' web) -m -u -i -n -p -w
```

...folyamatban...

## Hálózatok

...folyamatban...

```bash
docker inspect web --format "{{.NetworkSettings.IPAddress}}"
docker inspect web --format "{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}"
```




