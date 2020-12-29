# Project: p07

## Description

The first step is the same as it was in project p07.
Start the proxy server:

```bash
cd nginxproxy
docker-compose up -d
```

Go to the web folder:

```bash
cd ../web
```

You can simply start a web server protected by HTTP authentication. The name and the password will come from environment variables.
I recommend you to use a more secure way in production. Create the .htpasswd file manually and mount it inside the container.

The htpasswd container will create .htpasswd automatically and exit.

In the ".env" file you can find two variables.
HTTPD_USER and HTTPD_PASS will be used in "docker-compose.yml"
by the "htpasswd" service to generate the password file and then the "httpd" service will read it from the common volume.


The "fixperm" service runs and exits similar to "htpasswd". It sets the permission of the files after the web server starts.

Use the "depends_on" option to control which service starts first.

At this point you need to have the XIP variable set as the [main README]](../../README.md) refers to it.

Alternative option: set the XIP variable in the ".env" file:

## Start the web server

```bash
docker-compose up -d
```

Open the web page in your browser (Ex.: p07.192.168.1.6.xip.io). You will get a password prompt.

Clean the project:

```bash
docker-compose down --volume
cd ../nginxproxy
docker-compose down --volume
```

[Back to the main page](../../README.md)