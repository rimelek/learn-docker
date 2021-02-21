======
Docker
======

System information
==================

.. code:: bash

  docker help
  docker info
  docker version
  docker version --format '{{json .}}' | jq # requires jq installed
  docker version --format '{{.Client.Version}}'
  docker version --format '{{.Server.Version}}'
  docker --version

Run a stateless DEMO application
=================================

.. code:: bash

  docker run --rm -p "8080:80" itsziget/phar-examples:1.0
  # Press Ctrl-C to quit


Play with the "hello-world" container
=====================================

Start "hello-world" container
-----------------------------

.. code:: bash

  docker run hello-world
  # or
  docker container run hello-world

Output:

.. code:: text

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

List containers
---------------

List running containers

.. code:: bash

  docker ps
  # or
  docker container ps
  # or
  docker container ls
  # or 
  docker container list

List all containers

.. code:: bash

  docker ps -a
  # or use the other alias commands

List containers based on the hello-world image:

.. code:: bash

  docker ps -a -f ancestor=hello-world
  # or
  docker container list --all --filter ancestor=hello-world

Delete containers
-----------------

Delete a stopped container

.. code:: bash

  docker rm containername
  # or
  docker container rm containername

Delete a running container:

.. code:: bash

  docker rm -f containername

If the generated name of the container is "angry_shaw"

.. code:: bash

  docker rm -f angry_shaw

Start a container with a name
-----------------------------

.. code:: bash

 docker run --name hello hello-world

Running the above command again results an error message since "hello" is already used for the previously started container.
Run the following command to check the stopped containers:

.. code:: bash

  docker ps -a

Or you can start the stopped container again by using its name:

.. code:: bash

  docker start hello

The above command will display the name of the container. You need to start it in "attached" mode in order to see the output:

.. code:: bash

  docker start -a hello

Delete the container named "hello"

.. code:: bash

  docker rm hello

Start a container and delete it automatically when it stops
-----------------------------------------------------------

.. code:: bash

  docker run --rm hello-world

Start Apache HTTPD webszerver
=============================

Start the container in the foreground. ("attached" mode)
--------------------------------------------------------

.. code:: bash

  docker run --name web httpd:2.4

There will be no prompt until you press "CTRL+C" to stop the container running in the foreground.

Start it in the background ("detached" mode)
--------------------------------------------

.. code:: bash

  docker rm web
  docker run -d --name web httpd:2.4

Now you can see the running container by executing :code:`docker ps`.

Check container logs
--------------------

Check the output of the container running in the background:

.. code:: bash

  docker logs web
  # or
  docker container logs web

Watch the output (logs) continuously

.. code:: bash

  docker logs -f web
  # Press Ctrl-C to stop watching

Open the webpage using an IP address
------------------------------------

Get the IP address:

.. code:: bash

  CONTAINER_IP=$(docker inspect web --format '{{.NetworkSettings.IPAddress}}')

You can test if the server is working using wget:

.. code:: bash

  wget -qO- $CONTAINER_IP

Output:

.. code:: html
  
  <html><body><h1>It works!</h1></body></html>

Use port forwarding
-------------------

Delete the container named "web" and forward the port 8080 from the host to the containers internal port 80:

.. code:: bash

  docker rm -f web
  docker run -d -p "8080:80" --name web httpd:2.4

Then you can access the page using host's IP address.

Work with the container's filesystem without building your own image
--------------------------------------------------------------------

Run a command inside a container:

.. code:: bash

  docker exec -it web ls -la

"Enter" the container

.. code:: bash

  docker exec -it web bash

"Enter" the container with nsenter (in the past):

.. code:: bash

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

It does not support Pseudo-TTY so some commands may not work.

Get all of the IP addresses
---------------------------

.. code:: bash

  docker inspect web --format "{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}"
