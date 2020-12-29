Build an image:

```bash
docker build -t localhost/p03_php .
```

Start the container:

```bash
docker run -d --name p03_php -p "8080:80" localhost/p03_php
```
Open in a web browser and reload the page multiple times.
You can see the output is different each time with more lines.

Now delete the container. Probably you already now how, but as a reminder I show you again:

```bash
docker rm -f p03_php
```

Execute the "docker run ..." command again and reload the example web page to
see how you have lost the previously generated lines and delete the container again.

Now start the container with a volume to preserve data:

```bash
docker run -d --mount source=p03_php_www,target=/var/www --name p03_php -p "8080:80" localhost/p03_php
```

This way you can delete and create the container repeatedly a you will never lose your data until you delete the volume.
You can see all volumes with the following command:

```bash
docker volume ls
# or
docker volume list
```

After you have deleted the container, you can delete the volume:

```bash
docker volume rm p03_php_www
```

[Back to the main page](../../README.md)