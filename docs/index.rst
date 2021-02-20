.. Learn Docker documentation master file, created by
   sphinx-quickstart on Sat Feb 20 20:55:28 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. _xip.io: http://xip.io

========================================
Welcome to Learn Docker's documentation!
========================================

This project contains examples and scripts to help you learn about Docker.

The examples were originally made for the participants of the Ipszilon Seminar in 2017 in Hungary. 
The virtual machines were created in the Cloud For Education system.
Some of the scripts may not be useful to you.

Before you begin, clone the git repository:

.. code:: shell

  git clone https://github.com/itsziget/learn-docker.git

Scripts
=======

install.sh
  contains the installation of all the necessary components except the scripts below. 
  You may need to restart your machine after the installation.

system/etc/profile.d/fixhost.sh
  It fixes the missing hostname in :code:`/etc/hosts`,
  so you will not see error messages after using "sudo". The script checks if the machine's
  hostname is in the hosts file and writes into the file if the hostname was missing.
  In case of Ubuntu 16.04 it can copied into /etc/profile.d/.

system/usr/local/bin/xip.sh
  `xip.io` generates domain names for the public DNS server based on
  the current WAN or LAN IP address of the host machine.
  It must be copied into /usr/local/bin/ with the filename "xip".
  When you execute "xip", a domain name will be shown (Ex.: 192.168.1.2.xip.io) which you can use for the examples.
  The command takes one optional parameter as a subdomain. Ex.: "xip web1". The result would be: web1.192.168.1.2.xip.io

system/etc/profile.d/xip.variable.sh
  It uses the xip command to set the XIP environment variable so
  you can use the variable in a docker-compose.yml too.

Make sure you each script is executable before you continue. However, the above scripts are optional and you may not need
them in a local virtual machine. If you don't want to rely on automatic IP address detection, set the XIP variable manually.

Example projects
================

Example projects are in the `learn-docker/projects` folder, so go to there.

.. code: shell
  
  cd learn-docker/projects


Check the existence of :code:`$XIP` variable since you will need it for some examples:

.. code: shell

  echo $XIP

If it does not exist or empty, then set the value manually or run the script below:

.. code: shell

  export XIP=$(ip route get 8.8.8.8 | grep -o 'src [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | awk '{print $NF}')
  # or if xip is already installed:
  export XIP=$(xip)

All off the examples were tested with Docker 20.10.1. The version of Docker Compose was 1.27.4.
You can try with more recent versions but some behaviour could be different in the future.

* [p04](projects/p04/README.md): Create a simple [Docker Compose](https://docs.docker.com/compose/) project.
* [p05](projects/p05/README.md): Communication of PHP and Apache HTTPD web serverwith the help of [Docker Compose](https://docs.docker.com/compose/).
* [p06](projects/p06/README.md): Run more [Docker Compose](https://docs.docker.com/compose/) project on the same port using [nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy).
* [p07](projects/p07/README.md): Protect your web server with HTTP authentication
* [p08](projects/p08/README.md): Memory limit test with PHP in a container.
* [p09](projects/p09/README.md): CPU limit test

.. toctree::
   :maxdepth: 2
   :caption: Projects:

   projects/p00
   projects/p01
   projects/p02
   projects/p03