===============
Getting started
===============

Docker CE vs Docker Desktop
===========================

Very important to know that Docker CE often referred to as Docker Engine is not the same as Docker Desktop.
Docker Desktop adds new features for development purposes, but it runs a virtual machine (yes, even on Linux)
so you will lose some features that you would be able to use with Docker CE.
Even though Docker Desktop is constantly developed and improved, as long as it runs a virtual machine, there will be differences that you need to be aware of.

This tutorial will mostly use Docker CE, but you can use Docker Desktop depending on your needs, however,
some of the examples might not work. Whenever an example requires Docker Desktop, it will be noted before the example.

Requirements
============

Install Docker
--------------
Docker can be installed from multiple sources.
Not all sources are officially supported by Docker Inc.
It is recommended to `follow the official way <https://docs.docker.com/engine/install/>`_ whenever it is possible.
Docker is not supported on all Linux distributions, although some distributions
have their own way to install Docker or Docker Desktop.
Keep in mind that in those cases it is likely that the developers of Docker or people on the Docker forum
can't help you and you need to rely on the community of the distribution you have chosen.

.. _concept_docker_ce:

Docker CE
  Docker Community Edition. It is free to use even for commercial projects, although it does not have commercial support.
  Docker CE is open source and the source code of the daemon is available on GitHub in `moby/moby <https://github.com/moby/moby>`_
  The source code of the client is in `docker/cli <https://github.com/docker/cli>`_
  Installation instructions for Linux containers in the official documentation:
  `engine/install/#server <https://docs.docker.com/engine/install/#server>`_
  For Windows containers you can follow the instructions of Microsoft:
  `Get Started: Prep Windows for Containers <https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment>`_
  This is the recommended way to run containers natively on the preferred operating system.

Docker EE
  Docker Enterprise Edition doesn't exist anymore. It was the enterprise version of Docker with commercial support
  until Mirantis bought Docker EE. See below.

Mirantis Container Runtime
  `Mirantis Container Runtime <https://www.mirantis.com/software/mirantis-container-runtime/>`_
  used for `Mirantis Kubernetes Engine <https://www.mirantis.com/software/mirantis-kubernetes-engine/>`_
  If you need commercial support (from Mirantis) this is the recommended way.

.. _getting_started_docker_desktop:

Docker Desktop
  Docker Desktop was created for two purposes:

  - It provides developer tools using a virtualized environment based on `LinuxKit <https://github.com/linuxkit/linuxkit>`_.
  - Running native Linux containers is not possible on Windows or macOS, only on Linux.
    Since Docker Desktop runs Docker CE in a virtual machine Docker Inc can support running Docker containers on macOS
    and Windows. Docker Inc is doing their best to make you feel you are running native Docker containers,
    but you need to keep in mind that you are not.

  `Docker Desktop <https://docs.docker.com/desktop/>`_ is not open source, even though LinuxKit is. You can use it on your computer for personal purposes,
  and it is free for small companies too. Check the official documentation for up-to-date information about whether
  it is free for you or not.
  At the time of writing this tutorial the short version of Docker Desktop terms is the following:

     "Commercial use of Docker Desktop in larger enterprises (more than 250 employees OR more than $10 million USD in
     annual revenue) requires a `paid subscription <https://www.docker.com/pricing/>`_."


Rancher Desktop
  Rancher Desktop is similar to Docker Desktop, although it is created for running specific version of Kubernetes.
  You can use it for running Docker containers, but you will not be able to use the developer tools of Docker Desktop.
  For the installation instructions, follow the official documentation:
  `Rancher Desktop <https://rancherdesktop.io/>`_
  If you want to know more about using Rancher Desktop with Docker Desktop on the same macOS machine,
  you can watch my Youtube video:
  `Docker Desktop and Rancher Desktop on the same macOS machine <https://www.youtube.com/watch?v=jaj5OCFQHxU>`_

Install Docker Compose v2
-------------------------

Docker Compose v2 is a Docker CLI plugin to run Docker Compose projects.
This is the recommended way to use Docker Compose.
Since Docker Compose could already be on your system after installing Docker, check the below command first:

.. code:: bash

  docker compose version

Use space between "docker" and "compose". If the "compose" subcommand doesn't work,
follow the official documentation for the installation instructions:
`Install Docker Compose <https://docs.docker.com/compose/install/>`_

jq for parsing json files
-------------------------

Some of the examples will use `jq <https://stedolan.github.io/jq/>`_.
Click the link for the installation instruction.

Operating system
----------------

Linux is always supported and I do my best to support Docker Desktop on macOS, but not all the examples
will work on macOS unless you run Linux in a virtual machine.

.. _clone_git_repo:

Clone the git repository
========================

.. code:: shell

  git clone https://github.com/rimelek/learn-docker.git learn-docker
  cd learn-docker

Scripts
=======

system/usr/local/bin/nip.sh
  `nip.io` generates domain names for the public DNS server based on
  the current WAN or LAN IP address of the host machine.
  It must be copied into /usr/local/bin/ with the filename "nip.sh",
  unless you want to keep everything in the repository and use a relative path
  to execute the script.
  When you execute "nip.sh", a domain name will be shown (Ex.: 192.168.1.2.nip.io) which you can use for the examples.
  The command takes one optional parameter as a subdomain. Ex.: "nip.sh web1". The result would be: web1.192.168.1.2.nip.io

system/etc/profile.d/nip.variable.sh
  It uses the nip command to set the NIP environment variable so
  you can use the variable in a docker-compose.yml too.
  On Linux, you could copy it to `/etc/profile.d/nip.variable.sh`,
  while on macOS, you could execute manually as described below in the
  "Example Projects" section.


Make sure that each script is executable before you continue.
However, the above scripts are optional and you may not need them in a local virtual machine.
If you don't want to rely on automatic IP address detection, set the NIP variable manually to your IP address like this

Example projects
================

Example projects are in the `projects` folder, so go there.

.. code: shell
  
  cd projects


Check the existence of the :code:`$NIP` variable since you will need it for some examples:

.. code:: shell

  echo $NIP

If it does not exist or empty, then set the value manually or run the script below:

.. code:: shell

  export NIP=$(../../../system/usr/local/bin/nip.sh)

  # or if nip.sh is already installed:
  export NIP=$(nip.sh)

All off the examples were tested with Docker 20.10.23. The version of Docker Compose was 2.15.1.
You can try different versions, but older versions might lack some new features.
If you use a more recent version and the tutorial doesn't work for you,
please contact me on GitHub by `opening a new issue <https://github.com/rimelek/learn-docker/issues>`_.