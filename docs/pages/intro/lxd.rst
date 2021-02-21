.. _yq: https://github.com/mikefarah/yq
.. _snap: https://snapcraft.io/

===
LXD
===

Before using Docker containers it's good to know a little about a similar tool.
LXD can run containers and also virtual machines with similar commands.
It uses LXC to run containers (as Docker did at the beginning) and Qemu-KVM to run virtual machines.
To install LXD 4.0 LTS you need `snap`_.

Install LXD 4.0 LTS
===================

.. code:: bash

  sudo snap install --channel 4.0/stable lxd

Now you need to initialize the configuration:

.. code:: bash

  lxd init

You will found the following questions:

1. | **Questin:** Would you like to use LXD clustering? (yes/no) [default=no]:
   | **Answer:** no
2. | **Question:** Do you want to configure a new storage pool? (yes/no) [default=yes]:
   | **Answer:** yes
3. | **Question:** Name of the new storage pool [default=default]
   | **Answer:** default
4. | **Question:*** Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:
   | **Answer:** zfs
5. | **Question:** Create a new ZFS pool? (yes/no) [default=yes]:
   | **Answer:** yes
6. | **Question:** Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]:
   | **Answer:** no
7. | **Question:** Size in GB of the new loop device (1GB minimum) [default=25GB]:
   | **Answer:** Choose a suitable size for you depending on how much space you have.
8. | **Question:** Would you like to connect to a MAAS server? (yes/no) [default=no]:
   | **Answer:** no
9. | **Question:** Would you like to create a new local network bridge? (yes/no) [default=yes]:
   | **Answer:** yes
10. | **Question:** What should the new bridge be called? [default=lxdbr0]:
    | **Answer:** lxdbr0
11. | **Question:** What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
    | **Answer:** auto
12. | **Question:** What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
    | **Answer:** none
13. | **Question:** Would you like LXD to be available over the network? (yes/no) [default=no]:
    | **Answer:** no
14. | **Question:** Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
    | **Answer:** no
15. | **Question:** Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
    | **Answer:** Optional. Type "yes" if you want to see the result of the initialization.

Remote repositories
===================

There are multiple available remote repositories to download base images.
For example: https://images.linuxcontainers.org

You can list all of them with the following command:

.. code:: shell

  lxc remote list

Search for images
=================

Pass :code:`<reponame>:<keywords>` to :code:`lxc image list`

.. code:: shell

  lxc image list images:ubuntu
  # or
  lxc image list images:ubuntu focal
  # or
  lxc image list images:ubuntu 20.04
  # or
  lxc image list ubuntu:20.04

Show image information
======================

To show information about a specific image use :code:`lxc image info` with :code:`<reponame>:<knownalias>`

.. code:: shell

  lxc image info ubuntu:f

Aliases are the names of the images with which you can refer to a specific image.
One image can have multiple aliases. The previous command's output is
a valid YAML so you can use `yq`_ to process it. 

.. code:: shell

  lxc image info ubuntu:focal | yq '.Aliases'


Start Ubuntu 20.04 container
============================

.. code:: shell

  lxc launch ubuntu:20.04 ubuntu-focal


List LXC containers
===================

.. code:: shell

  lxc list

Enter the container
===================

.. code:: shell

  lxc exec ubuntu-focal bash

Then just use :code:`exit` to quit the container.

Delete the container
====================

.. code:: shell

  lxc delete --force ubuntu-focal

Start Ubuntu 20.04 VM
=====================

You can even create a virtual machine instead of container if you have at least LXD 4.0 installed on your machine.

.. code:: shell

  lxc launch --vm ubuntu:20.04 ubuntu-focal-vm


It will not work on all machines, only when Qemu KVM is supported on that machine.