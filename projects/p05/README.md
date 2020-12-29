Build PHP image and start the containers:

```bash
docker-compose up -d
```

Start multiple container for PHP:

```bash
docker-compose up -d --scale php=2
```

List the containers to see PHP has multiple instance:

```bash
docker-compose ps
```

Open the page in your browser and you can see the hostname in the first line is not constant. It changes but not every time, although the data is permanent.

Delete everything created by Docker Compose for this project:

```bash
docker-compose down --volume
```

[Back to the main page](../../README.md)