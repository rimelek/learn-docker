# Project: p07

## Description

At this point the nginx proxy must be already running. See it in the previous example: [p06-os projekt-ben](../p06/README.md).

You can simply start a web server protected by HTTP authentication. The name and the password will come from environment variables.
I recommend you to use a more secure way in production. Create the .htpasswd file manually and mount it inside the container.

The htpasswd container will create .htpasswd automatically and exits.

In the [.env](https://github.com/itsziget/learn-docker/tree/master/projects/p07/.env) file you can find two variables.
HTTPD_USER and HTTPD_PASS will be used in [docker-compose.yml](https://github.com/itsziget/learn-docker/tree/master/projects/p07/)
by the "htpasswd" service to generate the password file and then the "httpd" service will read it from the common volume.


The "fixperm" service runs exits similar to "htpasswd". It sets the permission of the files after the web server starts.

Use the "depends_on" option to control which service starts first.

## Start the web server

```bash
docker-compose up -d
```

Open the web page in your browser (Ex.: p07.X.X.X.X.xip.io). You will get a password prompt.
Remember, you can use the xip command to generate the domain name:

```bash
xip p07
```


[Back to the main page](../../README.md)