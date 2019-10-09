Build an image:

```bash
docker build -t y/p03_php .
```

Start the container:

```bash
docker run -d --name p03_php -p "8080:80" y/p03_php
```

Start the container with a volume:

```bash
docker run -d --mount source=p03_php_www,target=/var/www --name p03_php -p "8080:80" y/p03_php
```

[Back to the main page](../../README.md)