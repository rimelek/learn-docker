Start the container:

```bash
docker run -d -v $(pwd)/www:/usr/local/apache2/htdocs:ro --name p01_httpd -p "8080:80" httpd:2.4
# or
docker run -d --mount type=bind,source=$(pwd)/www,target=/usr/local/apache2/htdocs,readonly --name p01_httpd -p "8080:80" httpd:2.4 
```

Generate a domain name:

```bash
xip
# example output:
# 192.168.1.2.xip.io
```

Test the web page:

```text
http://192.168.1.2.xip.io:8080
# output:
# Hello Docker (p01)
```
[Back to the main page](../../README.md)