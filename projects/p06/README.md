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

At this point you need to have the XIP variable set as the [main README]](../../README.md) refers to it.

Alternative option: set the XIP variable in the ".env" file:

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

Both of the services are available on port 80. Example:

```text
http://web1.192.168.1.6.xip.io
http://web2.192.168.1.6.xip.io
```

This way you do not need to remove a container just because it is running on the same port you want to use for a new container.

Clean the project:

```bash
docker-compose down --volume
cd ../web1
docker-compose down --volume
cd ../nginxproxy
docker-compose down --volume
```

[Back to the main page](../../README.md)