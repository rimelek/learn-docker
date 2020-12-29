Building an image:

```bash
docker build -t localhost/p02_httpd .
```

The dot character at the and of the line is important and required.

Start container:

```bash
docker run -d --name p02_httpd -p "80:80" localhost/p02_httpd
```

You can open the website from a web browser on port 80.
The output should be "Hello Docker (p02)"

[Back to the main page](../../README.md)
