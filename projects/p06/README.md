Create the proxy network:

```bash
docker network create public_proxy
```

Check the networks:

```bash
docker network ls
```

Navigate to the nginxproxy folder

```bash
cd nginxproxy
```

Start the proxy:

```bash
docker-compose up -d
```

Navigate to the web1 folder:

```bash
cd ../web1
```

Start the containers:

```bash
docker-compose up -d
```

Navigate to the web2 folder:

```bash
cd ../web2
```

Start the containers:

```bash
docker-compose up -d
```

Both of the services are available on port 80:

```text
http://web1.193.x.x.x.xip.io
http://web2.193.x.x.x.xip.io
```

[Back to the main page](../../README.md)