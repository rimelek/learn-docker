{% raw %}
# LXD

Available remote servers to download base images.

https://images.linuxcontainers.org

```bash
lxc remote list
```

```bash
lxc image list images:ubuntu
# or
lxc image list images:ubuntu focal
# or
lxc image list images:ubuntu 20.04
# or
lxc image list ubuntu:20.04
```

List all aliases using one known alias

```bash
lxc image info ubuntu:x
```

It is a valid YAML so you can use [yq](https://github.com/mikefarah/yq) to process it. 

```bash
lxc image info ubuntu:focal | yq '.Aliases'
```

Start Ubuntu 20.04

```bash
lxc launch ubuntu:20.04 ubuntu-focal
```

List LXC containers

```bash
lxc list
```

Enter the container

```bash
lxc exec ubuntu-focal bash
```

Delete the container

```bash
lxc delete --force ubuntu-focal
```

You can even create a virtual machine instead of container if you have at least LXD 4.0 installed on your machine.

```bash
lxc launch --vm ubuntu:20.04 ubuntu-focal-vm
```

It will not work on all machines, only when Qemu KVM is supported on that machine. It also requires further configuration which is not part of this tutorial.

# Docker

## About the system

```bash
docker help
docker info
docker version
docker version --format '{{json .}}' | jq # requires jq installed
docker version --format '{{.Client.Version}}'
docker version --format '{{.Server.Version}}'
docker --version
```

## Test a stateless DEMO application

```bash
docker run --rm -p "8080:80" itsziget/phar-examples:1.0
# Press Ctrl-C to quit
```

## Demo "hello-world" image

Start the container:

```bash
docker run hello-world
# or
docker container run hello-world
```
Output:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```     

List running containers

```bash
docker ps
# or
docker container ls
# or 
docker container list
```

List all containers

```bash
docker ps -a
```

List containers based on the hello-world image:

```bash
docker ps -a -f ancestor=hello-world
# or
docker container list --all --filter ancestor=hello-world
```

Delete a stopped container

```bash
docker rm containername
# or
docker container rm containername
```

Delete a running container:
```bash
docker rm -f containername
```

If the generated name of the container is "angry_shaw"

```bash
docker rm -f angry_shaw
```

Start a container with a name:

```bash
docker run --name hello hello-world
```

Running the above command again results an error message since "hello" is already used for the previously started container.
Run the following command to check the stopped containers:

```bash
docker ps -a
```

Or you can start the stopped container again by using its name:

```bash
docker start hello
```

The above command will display the name of the container. You need to start it in "attached" mode in order to see the output:

```bash
docker start -a hello
```

Delete the container named "hello"

```bash
docker rm hello
```

Start a container and delete it automatically when it stops.

```bash
docker run --rm hello-world
```

## Apache HTTPD webszerver

Start the container in the foreground. ("attached" mode)

```bash
docker run --name web httpd:2.4
```

There will be no prompt until you press "CTRL+C" to stop the container running in the foreground.

Start it in the background as a daemon:

```bash
docker rm web
docker run -d --name web httpd:2.4
```
Now you can see the running container by executing "docker ps".

Check the output of the container running in the background:

```bash
docker logs web
# or
docker container logs web
```

Watch the output (logs) continuously

```bash
docker logs -f web
# Press Ctrl-C to stop wathcing
```

Get the local IP address of the container:

```bash
CONTAINER_IP=$(docker inspect web --format '{{.NetworkSettings.IPAddress}}')
```

You can test if the server is working using wget:

```bash
wget -qO- $CONTAINER_IP
```
Output:
```html
<html><body><h1>It works!</h1></body></html>
```

Delete the container named "web" and forward the port 8080 from the host to the containers internal port 80:

```bash
docker rm -f web
docker run -d -p "8080:80" --name web httpd:2.4
```

## Work with the container's filesystem without building your own image:

Run a command inside a container:

```bash
docker exec -it web ls -la
```

"Enter" the container

```bash
docker exec -it web bash
```

"Enter" the container with nsenter (in the past):

```bash
CONTAINER_PID=$(docker inspect --format '{{ .State.Pid }}' web)
sudo nsenter \
  --target $CONTAINER_PID \
  --mount \
  --uts \
  --ipc \
  --net \
  --pid \
  --cgroup \
  --wd \
  env -i - $(sudo cat /proc/$CONTAINER_PID/environ | xargs -0) bash
```

It does not support Pseudo-TTY so some commands may not work.

## Networks

```bash
docker inspect web --format "{{.NetworkSettings.IPAddress}}"
docker inspect web --format "{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}"
```

[Back to the main page](../../README.md)

{% endraw %}