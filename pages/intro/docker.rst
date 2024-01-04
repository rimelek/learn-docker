.. _user namespace in a Docker container: https://docs.docker.com/engine/security/userns-remap/
.. _Kata Containers: https://katacontainers.io/
.. _Install Kata Containers: https://github.com/kata-containers/kata-containers/tree/main/docs/install

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

Start an Ubuntu container
=========================

Start Ubuntu in foreground  ("attached" mode)
---------------------------------------------

.. code:: bash

  docker run -it --name ubuntu-container ubuntu:20.04
  
Press :code:`Ctrl+P` and then :code:`Ctrl+Q` to detach from the container
or type :code:`exit` and press :code:`enter` to exit bash and stop the container.

Start Ubuntu in background ("detached" mode)
--------------------------------------------

Linux distribution base Docker images usually don't contain Systemd as LXD images
so these containers cannot run in background unless you pass :code:`-it`
to get interactive terminal. It wouldn't be necessary with a container
which has a process inside running in foreground continuously.
:code:`-it` works with other containers too as long as
the containers command is "bash" or some other shell. 

.. code:: bash

  docker rm -f ubuntu-container
  docker run -it -d --name ubuntu-container ubuntu:20.04

.. note::

  Actually only :code:`-i` or :code:`-t` would be enough to keep the container
  in the background, but if you want to attach the container later, it requires
  both of them. Of course, :code:`-d` is always required.

Attach the container
--------------------

You can attach the container and see the same as you could see
when you run a container without :code:`-d`, in foreground.
You can even interact with the container's main process so be careful
and don't execute a command like :code:`exit`, or you will stop the whole
container by stopping its main process.

.. code:: bash

  docker attach ubuntu-container

Press Ctrl+P and then Ctrl+Q to quit without stopping the container.

The better way to "enter" the container is :code:`docker exec` which
is similar to the way of LXD.

.. code:: bash

  docker exec -it ubuntu-container

Now you can use the "exit" command to quit the container and leave it running.

Start Apache HTTPD webserver
============================

Start the container in the foreground
-------------------------------------

.. code:: bash

  docker run --name web httpd:2.4

There will be no prompt until you press "CTRL+C" to stop the container running in the foreground.

.. note::

  When you change your terminal window it will send SIGWINCH signal to the container
  and shut down the server. Use it only for some quick test.

Start it in the background
--------------------------

.. code:: bash

  docker rm web
  docker run -d --name web httpd:2.4

.. note::

  You don't need to use :code:`-it` and you should not use that either.
  Running HTTPD server container with and interactive terminal
  will send SIGWINCH signal to the container and shut down the HTTPD server
  immediately when you try to attach it.

  Even without :code:`-it`, attaching the HTTPD server container
  will shut down the server when you change the size of your terminal window.

  Use :code:`docker logs` instead. 

Check container logs
--------------------

:code:`docker logs` shows the standard error and output of a container
without attaching it. Actually it will read and show the content of
the log file which was saved from the container's output.

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

  CONTAINER_IP=$(docker container inspect web --format '{{.NetworkSettings.IPAddress}}')

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

Then you can access the page using the host's IP address.

How we could enter a container in the past
------------------------------------------

Before :code:`docker exec` was introduced, :code:`nsenter`
was the only way to enter a container.
It does almost the same as :code:`docker exec`
except it does not support Pseudo-TTY so some commands may not work.

.. code:: bash

  CONTAINER_PID=$(docker container inspect --format '{{ .State.Pid }}' web)

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

As you can see, :code:`nsenter` runs a process inside specific Linux namespaces.

Share namespaces
----------------

.. code:: bash

  docker rm -f web
  docker run -d --name web \
    --net host \
    --uts host \
    --pid host \
    httpd:2.4

This example shows how you can share the host's namespaces
with the container.

- **net**: The container will not get a virtual network.
  Localhost inside the container will be the same as localhost on the host operating system.
- **uts**: When you enter the container you will see that the hostname in the prompt 
  is the same as you can see on the host. Without this, the container had a random hash as hostname.
- **pid**: The container can see every process running on the host and not just inside the container.

.. note::

  Using `user namespace in a Docker container`_ is disabled by default

.. note::

  Since Docker Desktop runs Docker CE in a virtual machine, sharing namespaces with the host means that you
  will use the namespace of the virtual machine, not the actual host operating system where you run the Docker client.
  As a result, you will still not be able to access ports on localhost of the host operating system, the hostname will
  be the hostname of the virtual machine and the processes inside the container will see the processes running
  inside the virtual machine only.

Now enter the container 

.. code:: bash

  docker exec -it web bash

and install the following tools, so you can see
host processes and network interfaces from the container.

.. code:: bash

  apt update
  apt install iproute2 procps psmisc

- **iproute2**: adds the :code:`ip` command
- **procps**: installs the :code:`ps` command
- **psmisc**: this makes :code:`pstree` command available

Now run 

- :code:`ip addr` to see network interfaces
- :code:`ps auxf` to see host processes
- :code:`pstree` to see the process tree

You can exit the container and run the following command to get
only the processes inside the container:

.. code:: bash

  docker exec web ps auxf $(docker container inspect --format '{{ .State.Pid }}' web)

Start Ubuntu virtual machine
============================

There are multiple ways to run a virtual machine with Docker.
Using a parameter is not enough. You need to choose a different runtime.
The default is :code:`runc` which runs containers.
One of the most popular and easiest runtime is `Kata Containers`_.

Follow the instructions to install the latest stable version of the Kata runtime: `Install Kata Containers`_
and configure Docker daemon to use it. An example :code:`/etc/docker/daemon.json`
is the following:

.. code:: json

  {
    "default-runtime": "runc",
    "runtimes": {
      "kata": {
        "path": "/usr/bin/kata-runtime"
      }
    }
  }

Now run 

.. code:: bash

  docker run -d -it --runtime kata --name ubuntu-vm ubuntu:20.04

It is still lightweight. You can run :code:`ps aux` inside to see
there is no systemd or other process like that, however, run the
following command on the host machine and see it has only one CPU core:

.. code:: bash

  docker exec -it ubuntu-vm cat /proc/cpuinfo
  