Build an image and start the container using [Docker Compose](https://docs.docker.com/compose/):

```bash
docker-compose up -d
```

Check the container:

```bash
docker-compose ps
# The name of the container: p04_php_1
```

Check the networks:

```bash
docker network ls
# New bridge network: p04_default
```

[Back to the main page](../../README.md)