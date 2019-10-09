Build PHP image and start the containers:

```bash
docker-compose up -d
```

Start multiple container for PHP:

```bash
docker-compose up -d --scale php=2
```

Open the page in your browser and you can see different hostname every time you reload the page.

[Back to the main page](../../README.md)