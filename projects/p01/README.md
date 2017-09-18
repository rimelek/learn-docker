Konténer indítása

```bash
docker run -d -v $(pwd)/www:/usr/local/apache2/htdocs:ro --name p01_httpd -p "8080:80" httpd:2.4
# vagy
docker run -d --mount type=bind,source=$(pwd)/www,target=/usr/local/apache2/htdocs,readonly --name p01_httpd -p "8080:80" httpd:2.4 
```

Domain generálása:

```bash
xip
# output:
# 193.x.x.x.xip.io
```
Weboldal tesztelése:

```text
http://193.x.x.x.xip.io:8080
# output:
# Hello Docker (p01)
```
[Vissza a főoldalra](../../README.md)