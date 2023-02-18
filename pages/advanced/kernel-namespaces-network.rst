.. _nicolaka/netshoot: https://hub.docker.com/r/nicolaka/netshoot

:og:image: https://ams03pap003files.storage.live.com/y4mjikSlU8xJP68WUPZ1K84w32mGAs-iXRpjMZA7XWsQy80gIzxY-nUDIF6X1GWQrEjJZnuMHUza2X2kmVQwoK0PUeiY4tCyHSFmsAcSzRfAZOTp7fQtO47ocHroiyYe6CjQWlQ3Dchntkb002ayLclh2_FfYHmam99vHAwYPRoEvs-nuJIeOBEvFc6jakeoZyi?width=1024&height=576&cropmode=none
:og:description: Learn about the network namespace and how you can use it for debugging and testing.

=================================================
Docker network and network namespaces in practice
=================================================

Linux Kernel Namespaces in general
==================================

Let's start with a simple example so we can understand why namespaces are useful.

.. image:: https://ams03pap003files.storage.live.com/y4m1n8TZUq1S6a4wCgpfkei-rnJHsvtcNULyw4cVjsPVblZo5ahi9pLCXYmmBQwH-mGePpXOXSjjwyIoOSdD8jZDmb-evAaciWiSxOankmwxfzspFKhF_hcCXHgbuZf9uIQqgJTHjW-PQaml-8qZhkEEWYiXki865ymC_MHzzgSTlLcwBBj2t7ghGfKf48i02pd?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

Let's say, you have a running PHP process on your Linux machine. That PHP process will be able to see
your entire host, including files, other running processes and all the network interfaces.
It will not just see the interfaces, it will be able to listen on all the IP addresses, so you have to
configure PHP to listen on a specific IP address.
PHP will also have internet access which is usually what you want, but not always.

This is when Linux kernel namespaces can help us.A kernel namespace is like a magick wall between a running process
and the rest of the host. This magick wall will only hide some parts of the host from a specific point of view.
In this tutorial we will mainly cover the three best known point of views.

- Filesystem (Mount namespace)
- Network (Network namespace)
- Process (PID namespace, which means "Process ID" namespace)

The first namespace is mount namespace. You could also remember it as "Jail" or "chroot".
It means the process will see only a folder on the host and not the root filesystem.
That folder could be empty, but it is very often a folder that contains very similar files
as the root filesystem does. This way PHP will "think" it is running on a different host
and it won't even know if there is anything outside that folder.

.. image:: https://ams03pap003files.storage.live.com/y4mzjrcPyuVn9OD1zYwNmEBN2pyox7VG1FQ_RmxFettn51tEtHuaAJUiHdC5cgro8cvuwTu4E4rlQMky1I7qCMklRt4o2F0OB-rVuihnArI3HcCO-yVj8jIXJptP47avmYzZAE4kGftN0LeCBK_xu1Vz_ckFq0GmP2BBL9Aw_cjfFyvOTSw2sYxoR8VL-wtLjAw?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

This is not always enough. Sometimes you don't want a specific process to see other processes on the host.
In this case you can use the PID namespace so the PHP process will not be able to see other processes on the host,
only the processes in the same PID namespace. Since on Linux there is always a process with the process ID 1 (PID 1),
for any process in the network namespace, PHP will have PID 1. For any process outside of that PID namespace,
PHP will have a larger process ID like 2324.

.. image:: https://ams03pap003files.storage.live.com/y4mxFENT6Q7HHAuAMs8cMVMbmDPPAXSEP8RW196gW0iUp9DCO0LqQLvkEI76UEMlzk6Rcaua1kBdZ16YqMlMGwy2r9yBPTyOikhfT7OSk_DSfcZdhJTsGAaJggTTSjS51UH69UNdBctkJdyBEYZxzZuhzhcmlvGZk-SxyJ07zSGkEtpnOMWoind3nAbU3xZvYjN?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

And finally we arrived to the network namespace. Network namespace can hide network interfaces from processes
in the namespace. The network namespace can have its own IP address, but it will not necessarily have one.
Thanks to the network namespace, PHP will only be able to listen its own IP address in a Docker network.

.. image:: https://ams03pap003files.storage.live.com/y4m56sZ2NrTbPALYdSQalVVVOUuS-X54NrBLeeYMKNXhHGbr7QjW9y1YX5qzFDSgRm0Sw3YlI65Fge7R3EpdeircZLwS2cXiqVpEf7ml9iSidaDmrELqFktZF3wqjhE4fhwIm1-zeKhpUsCnFi_SlRsHkRtxgzgfL7qaK6OyHR1ou3l1lXKjQ8mHDwTkGfcoK-C?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

These namespaces are independent and not owned by the PHP process. Any other process could be added to these namespaces,
and you don't need to run those processes in each namespace.

.. image:: https://ams03pap003files.storage.live.com/y4mtcvQh0D9f6yXwWqGuKJt7FEtfqYE5Ys-Mw0ke22z26QotmvwzYGeX_CjH-ltZi5CLVX6bG2h8eXkbFfp4PCBMSCi-jQKZvA66Ta5EkHdiiuoU9SE4ouQyt4w_rWTu293SG6mqBDL3bXIu0IFeBoHwbiH6CGe21b4YwPiahAgIy0Ef3AVWe4iZl471yi9LY2Z?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

You can choose the network namespace even without the mount namespace, so you can use an application
(web browser, curl) on the host and run it in the network namespace of the PHP process, so even if
the PHP is not available outside of the container, running the browser in the network namespace of
the container will allow you to access your website.

Network traffic between a container and the outside world
=========================================================

Your host machine usually has a network interface which is connected to the internet or at least to a local network.
We will call it "the outside world".

.. image:: https://ams03pap003files.storage.live.com/y4mFhcL1bVgyENw2zODj83Dq1Do9pAtW1Vu_LJyWvZX6h0ZKJHBiR1pJPZC9OnxHcM8S2h3wSczzH5i78a66BQ0FneBmaCs3RnroUGpRQq7-7qRf3NbdZREZUeRcrJzrjsyLpIjpQHleA4sTUWByNPgmvXYHsbZ3oJZKsNktcCVWqqFKjuC3ApTgmwhUy7KBLiF?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

This interface could be "eth0", although recently it is more likely to be something like "enp1s0" or "eno1".
The point is that traffic routed through this interface can leave the host machine. The container needs
its own network interface which is connected to another outside of the container on the host. The name of the interface
on the host will start with "veth" followed by a hash.

.. image:: https://ams03pap003files.storage.live.com/y4mQMfMohZTsJLikmtdvp-yoAVD4AyXmudA8rLFTkY_vfBwVQMl3Rv3zIlbNHi9lwMMuitYSDXTOWdcpb6nyvQFkhI7bSTkuYyI5kHqZTN9jjsnSgWpGjQOlFIdcmSnBxJ6QY2yf2U54lAErzJ2MVJ9zFXC8u36_pCe-Ejd4qO2zjRx05KmMR0XyHLETQyN3wt8?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

The veth interface will not have IP address. It could have, but Docker uses a different way so containers in the same
Docker network can communicate with each other. There will be a bridge network between the veth interface and eth0.
The the bridge of the default Docker network is "docker0".

.. image:: https://ams03pap003files.storage.live.com/y4majKY-A1ONQ4ymytVBW1-7ZXQyw1Q8DWGhqd1Pku8ofvzee8cgqkkjAtZDJ1SG5g4KFROeTswcxTglBK_4XEmktQtxvxnx8Eg5JJJKuYEOatgDeRUykZro2MbiVPogNfjg8EmLZeHQXQ9r_-BcPc5tMfbMggRVsLJipqb2NktZszCvxvMlzqk3tMOD0xUq3R2?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

This bridge will have an IP address which will also be the gateway for each container in the default Docker network.
Since this is on the host outside of the network namespace, any process running on the host could listen on this IP
address so processes running inside the container could use this IP to access a webservice listening on it.

Sometimes you don't want a containerized process to access the internet, because you don't trust an application
and you want to test or run it without internet access for security reasons indefinitely. This is when
"internal networks" can help.

.. image:: https://ams03pap003files.storage.live.com/y4mppUzYKGFL3m29qkojJsrZ04p08epKXHllkDNM1T_mfW8KyEZ9MFmklxHqUrSWfo66V0YfA4XWalAHO5jTW76fuNjiwaM_Rea1VIUOZOTBmmfJFKqIBqPKat9Ytnoq6AnIqpM5icNg6jjPZ44Y2HCn6xeppNz4vmAUKiqz0lYOvQwofrUkKUOe-zeXrqMvtEZ?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

.. _internal_network_port_forward:

Containers don't accept port forwards on IP addresses in internal networks so it is not just rejecting
outgoing traffic to the outside world, but also rejecting incoming requests from other networks.

You can create a user-defined Docker network which will have a new bridge. If you also define that network as "internal"
using the following command for example

.. code:: bash

  docker network create secure_net --internal

the network traffic will not be forwarded from the bridge to eth0 so PHP will only be able to access services
running on the host or in the container.

There is another very important interface called "lo" better known as "localhost" which usually has an IP address like
:code:`127.0.0.1`. This is however not the only IP address that is bound to this interface. Every part of the IP could
be changed after :code:`127.` and still pointing to the same interface. It is important to know that every network
namespace has its own localhost.

Let's see what it means.

.. image:: https://ams03pap003files.storage.live.com/y4mrSPlwK5dG8gpAqcK-T4zOEgFpZrvMclsrhkRSEIYzJzMcoWV1Xm79u8vqyaoHyhBI83oTkwvCqN5a6F7qD0vHix4qK9jZXZ3ry3n3_JIfb4-F4mrPfDwdkqxraMdblvCbdtCyFZS47jiYIJy8LeWQnFuBNWKTizWnihSPEwUTtv8A4cZEw55wigmtbpJyP4X?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

If the web application is listening on port 80 on localhost, a web browser outside of the container will not be
able to access it, since it has a different localhost. The same is true when for example a database server
is running on the host listening on port 3306 on localhost. The PHP process inside the container
will not be able to reach it.

.. image:: https://ams03pap003files.storage.live.com/y4mfY8MswymXiqlxXUWUc90hHvRaSDOeqODcvK64ssgsNLpAh8xKwxZh4uGM3wpBZgJNjr5JaVYaqa3npDIQ5D-3NgGonwgGt4QE3KsgySwW4n7tY6cKzDlQaAfJyl-ARTRnlorF0lvGNhfhSLVZhKRCUwxS2DzBf1IcwRkpqZ9dXLCnlkJyp5v4AM85ajyG8xH?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

Since the reason is the network namespace, you could just run the container in host network mode

.. code:: bash

  docker run -d --name php-hostnet --network host itsziget/phar-examples:1.0

which means you just don't get the network isolation. The host network mode does not mean that you are using
a special Docker network. It only means you don't want the container to have its own network namespace.

.. image:: https://ams03pap003files.storage.live.com/y4mwLozQ9rgLbY3Mol-61Dh72xV0tY109mpEmvwb4tfz068zF5GaoycLeN_4dQ3yIIGy0wTnC7moh-oP0Vi5otpmetAVDmGo5r3aHsYxe6o28Bs5dVNIu4_4zoZxy32V-xRAaAS6yapJgYb8pAByCTZJddBdZ_uli3yTrkqZl9NYKzgpfa8jvdpj6uP3t_0x18R?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

Of course we wanted to have the network isolation and we want to keep it. The other solution is running another
container which will use the same network namespace.

.. image:: https://ams03pap003files.storage.live.com/y4m73QYpsCMLY_5zzZwYye7Vr9mSh4YB1BMmuG7Tl0i_vm6fu2R9GEB8m0HEc20FsWBDOS2TuW-TlWXphPcYq1wrQHEnN7A2RNBFULDC62TmnPnzop3jTrbMkO0tPtLoO-4vcqPjVctPAKNUMUqu02CX-0KqufP3Ghcq0SMSDpTjjVfsR25_9xZ3wDQhhikV11E?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

Manipulating network namespaces
===============================

Docker is not the only tool to manipulate namespaces. I will show you the following tools.

- Container engines (Docker)
- "ip" command
- "nsenter" command
- "unshare" command

Two containers using the same network namespace
-----------------------------------------------

Of course the first we have to talk about is still Docker. The following commands will start a PHP demo application
and run a bash container using the same network namespace as the PHP container so we can see the
network interfaces inside the PHP container.

.. code:: bash

  docker run -d --name php itsziget/phar-examples:1.0
  docker run --rm -it --network container:php bash:5.1 ip addr

There is a much easier solution of course. We can just use :code:`docker exec` to execute a command
in all of the namespaces of the PHP container.

.. code:: bash

  docker exec php ip addr

This command works only because "ip", which is part of the "iproute2" package is installed inside the PHP container,
so it wouldn't work with every base image and especially not with every command.

"nsenter": run commands in any namespace
----------------------------------------

The "nsenter" (namespace enter) command will let you execute commands in specific namespaces.
The following command would execute :code:`ip addr` in the network namespace of a process which has the
process ID :code:`$pid`.

.. code:: bash

  sudo nsenter -n -t $pid ip addr

We have to get the id of a process running inside a container. Remember, the process has a different ID
inside and outside of the container because of the PID namespace, so we can't just run the :code:`ps aux` command
inside the container. We need to "inspect" the PHP container's metadata.

.. code:: bash

  pid="$(docker container inspect php --format '{{ .State.Pid }}')"

The above command will save the process ID in the environment variable called "pid". Now let's
run nsenter again.

.. code:: bash

  sudo nsenter -n -t $pid ip addr
  sudo nsenter -n -t $pid hostname
  sudo nsenter -n -u -t $pid hostname

The first command will show us the network interfaces inside the network namespace of the PHP container.
The second command will try to get the hostname of the container, but it will return the hostname of the host machine.
Although the hostname is related to the network in our mind, it is not part of the network namespace.
It is actually the part of the UTS namespace. Since the long name of the namespace would just confuse you,
I will not share it at this point of the tutorial. The good news is that we can also use the UTS namespace of the
container by adding the :code:`-u` flag to the "nsenter" command, and this is what the third line does.

"ip netns" to create new network namespaces
-------------------------------------------

"nsenter" was great for running commands in existing namespaces. If you want to create network namespaces,
you can use the :code:`ip netns` command, but before we create one, let's list existing network namespaces:

.. code:: bash

  ip netns list

The above command will give you nothing even if you have running containers using network namespaces.
To understand why, first let's look at content of two folders

.. code:: bash

  ls /run/netns
  sudo ls /run/docker/netns

The first line, used by the "ip" command will not give you anything, but the second
will give you at least one file, which is the file of the network namespace of our previously
started PHP container.

As you can see, if you want to work with namespaces, you need to refer to a file or the name of the file.
Docker and the "ip" command uses a different folder to store those files. These files are not the only way
to refer to network namespaces and we will discuss it later.

It's time to create our first network namespace without Docker.

.. code:: bash

  sudo ip netns add test
  ls /run/netns

The "ls" command isn't required here, but can show us that we indeed created a file. Let's run
:code:`ip addr` inside our new network namespace:

.. code:: bash

  sudo ip netns exec test ip addr

.. note::

  You could actually use nsenter to run :code:`ip addr` in a network namespace even if you don't have an existing
  process.

  .. code-block:: bash

    sudo nsenter --net=/run/netns/test ip addr

The output will be

.. code:: text

  1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

As you can see this new network namespace doesn't even have a loopback IP address so basically
it doesn't have "localhost". It shows us that a network namespace does not give us a fully configured
private network, it only gives us the network isolation. Now that we know it, it is not surprising
that the following commands will give us error messages.

.. code:: bash

  sudo ip netns exec test ping dns.google
  # ping: dns.google: Temporary failure in name resolution
  sudo ip netns exec test ping 8.8.8.8
  # ping: connect: Network is unreachable

Since this network namespace is useless without further configuration and configuring the network
is not part of this tutorial, we can delete it:

.. code:: bash

  sudo ip netns del test

"unshare": Temporary network namespace creation
-----------------------------------------------

If you want to create a temporary network namespace and run a command inside it, you can use :code:`unshare`.
This command has similar parameters as :code:`nsenter` but it doesn't require existing namespaces. It will
create new namespaces for the commands that you want to run. IT could be useful when you just want to test
an application that you it shouldn't use the network so you can run it in a safer environment.

.. code:: bash

  sudo unshare -n ip addr

It will give you the same output as our previous attempt to create a network namespace.

.. code:: text

  1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

Working with Docker's network namespaces
----------------------------------------

Allow the "ip" command to use Docker's network namespaces
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

If you want, you could remove :code:`/run/netns` and create a symbolic link instead pointing to
:code:`/run/docker/netns`.

.. code:: bash

  sudo rm -r /run/netns
  sudo ln -s /run/docker/netns /run/netns
  ip netns list

Sometimes you can get an error message saying that

.. error::  rm: cannot remove '/run/netns': Device or resource busy

Since we started to use the "ls" and "ip" commands to list namespaces, it is likely that
we get this error message even though we are not actively using that folder. There could
be two solutions to be able to remove this folder:

- Exiting from current shell and opening a new one
- Rebooting the machine

The first will not always work, and the second is obviously something that you can't do
with a running production server.

A better way of handling the situation is creating symbolic links under :code:`/run/netns`
pointing to files under :code:`/run/docker/netns`. In Docker's terminology the file is called
"sandbox key". We can get the path of a container's sandbox key by using the following command:

.. code:: bash

  sandboxKey=$(docker container inspect php --format '{{ .NetworkSettings.SandboxKey }}')

The end of that path is the filename which we will need to create a link under :code:`/run/netns`.

.. code:: bash

  netns=$(basename "$sandboxKey")

Using the above variables we can finally create our first symbolic link

.. code:: bash

  sudo ln -s $sandboxKey /run/netns/$netns

Finally, :code:`ip netns ls` will give us an output similar to the following:

.. code:: text

  a339e5fc43f0 (id: 0)

Name resolution issue with "ip netns exec"
++++++++++++++++++++++++++++++++++++++++++

It's time to run :code:`ip netns exec` to test the network of a Docker container.

.. code:: bash

  sudo ip netns exec $netns ip addr
  sudo ip netns exec $netns ping 8.8.8.8
  sudo ip netns exec $netns ping dns.google

The first two lines will give the expected results, but the third line will give us the following
error message.

.. error:: ping: dns.google: Temporary failure in name resolution

What happened?

.. image:: https://ams03pap003files.storage.live.com/y4mbufvZdt6vshWKx-Kj1MXkOxlAZPhaViscJpKdqIG27H8QhKw4Nprd5tqpYRGppDDIjkj3jRBlYWAfdbl5enP2dYold3sN-Akchx8cT-7043rfEh07Fl1n4dH9KZpPIN5dCg0vh85fezDbqBuim9ff3VGIznDMHXFT5bH4M9bTeAD034WCXxD2P7-EnzaJO4E?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

We ran the ping command only in the network namespace of the container, which means the configuration files
that are supposed to control how name resolution works are loaded from the host. My host was an Ubuntu 20.04 LTS
virtual machine created by `Multipass <https://multipass.run/>`_. By default, the IP address of the nameserver
is `127.0.0.53`. Remember, that this IP address belongs to the loopback interface which is different in each
network namespace. In the network namespace of our PHP container there is no service listening on this IP address.

Solution 1: Change the configuration on the host
++++++++++++++++++++++++++++++++++++++++++++++++

.. danger::

  DO NOT test it in a production environment as it could also break your name resolution if you are doing something
  wrong.

:code:`/etc/resolv.conf` is usually a symbolic link pointing one of the following files:

- :code:`/run/systemd/resolve/stub-resolv.conf`
- :code:`/run/systemd/resolve/resolv.conf`

Depending on your system it could point to an entirely different file or it could also be a regular file instead of
a symbolic link. I will only discuss the above files in this tutorial.

Run the following command to get the real path of the configuration file.

.. code:: bash

  readlink -f /etc/resolv.conf

.. note::

  Alternatively, you could also run :code:`realpath /etc/resolv.conf`

If the output is :code:`/run/systemd/resolve/stub-resolv.conf`, you are using the stub resolver and the content of
the file looks like this without the comments:

.. code:: text

  nameserver 127.0.0.53
  options edns0 trust-ad
  search .

On the other hand, :code:`/run/systemd/resolve/resolv.conf` will directly contain the nameservers:

.. code:: text

  nameserver 192.168.205.1
  search .

Now I will change the symbolic link:

.. code:: bash

  sudo unlink /etc/resolv.conf
  sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

After this I will be able to successfully ping the domain name of Google's name server:

.. code:: bash

  sudo ip netns exec $netns ping dns.google

I don't want to keep this configuration, so I will restore the stub resolver:

.. code:: bash

  sudo unlink /etc/resolv.conf
  sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

Solution 2: Using per-namespace resolv.conf
+++++++++++++++++++++++++++++++++++++++++++

We can create additional configuration files for each network namespace.
First we have to create a new folder using the name of the namespace undr :code:`/etc/netns`

.. code:: bash

  sudo mkdir -p /etc/netns/$netns


After that we have to create a :code:`resolv.conf` file in the new folder and add a nameserver definition like
:code:`nameserver 8.8.8.8`

.. code::

  echo "nameserver 8.8.8.8" | sudo tee /etc/netns/$netns/resolv.conf

And finally we can ping the domain name

.. code::

  sudo ip netns exec $netns ping dns.google

Solution 3: Using a custom mount namespace based on the original root filesystem
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

This is a very tricky solution which I would not recommend usually, but it could be useful
to learn about the relation of different types of namespaces. The solution is based on the following facts.

- The "nsenter" command allows us to define a custom root directory (mount namespace) instead of using an existing mount
  namespace
- The "mount" command has a :code:`--bind` flag which allows us to "bind mount" a folder to a new location.
  This is similar to what Docker does if you choose "bind" as the type of a volume.
  See `Bind mounts | Docker <https://docs.docker.com/storage/bind-mounts/>`_
- There are some folders that are not part of the root filesystem, so when we mount the root filesystem
  we don't mount those folders. :code:`/run` is on :code:`tmpfs`, so it is stored in memory.
- Mounting a file over a symbolic link is not possible, but mounting over an empty file which is a target
  of a symbolic link works.

.. image:: https://ams03pap003files.storage.live.com/y4mtBjb3SWEr509GikMqcFifbSbWvRHVqnRPaGKnfhKZa2saQwrhiU_aapdOhAs7lqmeypQsNL3_XYZw_B4XykZYaBgwzXbcd6ztRXe5TGwjUVev79gw3zuit-W3j-0lJoAAxb2u6ATf8qQ-sDHwcwKcKQgcvkOnzI0bmguPPWrkHM4sLFAxW5IjurrDIVS_X9g?width=1024&height=458&cropmode=none
  :width: 660
  :height: 295

First we will set the variables again with an additional :code:`project_dir` which you can change if you want

.. code:: bash

  sandboxKey=$(docker container inspect php --format '{{ .NetworkSettings.SandboxKey }}')
  netns=$(basename "$sandboxKey")
  pid="$(docker container inspect php --format '{{ .State.Pid }}')"

  project_dir="$HOME/projects/netns"

Then we create the our project directory

.. code:: bash

  mkdir -p "$project_dir"
  cd "$project_dir"

Mount the system root to a local folder called "root".

.. code:: bash

  mkdir -p root
  sudo mount --bind / root

Since "run" is on tmpfs and it wasn'T mounted, we create an empty file to work as a placeholder for the target
of the symbolic link at :code:`/etc/resolv.conf`

.. code:: bash

  sudo mkdir -p "root/run/systemd/resolve/"
  sudo touch "root/run/systemd/resolve/stub-resolv.conf"

Now we can copy the :code:`resolv.conf` that contains the actual name servers and mount it over our placeholder
:code:`stub-resolv.conf`.

.. code:: bash

  cp "/run/systemd/resolve/resolv.conf" "resolv.conf"
  sudo mount --bind "resolv.conf" "root/run/systemd/resolve/stub-resolv.conf"

And finally we can run the following nsenter command.

.. code::

  sudo nsenter -n --root=$PWD/root --target=$pid ping dns.google

Now nsenter will use :code:`$PWD/root` as the filesystem of the new mount namespace and use the network namespace of
the PHP container to run ping.

.. code:: text

  PING dns.google (8.8.4.4) 56(84) bytes of data.
  64 bytes from dns.google (8.8.4.4): icmp_seq=1 ttl=112 time=11.5 ms
  64 bytes from dns.google (8.8.4.4): icmp_seq=2 ttl=112 time=12.1 ms
  64 bytes from dns.google (8.8.4.4): icmp_seq=3 ttl=112 time=11.7 ms

Debugging the Minotour
-------------------------

.. image:: https://ams03pap003files.storage.live.com/y4ma1e5P3H-skpwTnHOUe_ME9rn3w3T4wukF93GCb5wMnJZLxpHydFZN0EiDF620u1mTkozX-QKGNJ0UceloGmfFeQDZu8J9K1vhV6Kg2Cpt8k3uw9K1I9ZFeYUyappE6EN8Vfy91F_jTKqvgYjmvXk0_Nk_kJqYR5bsTI9haf7OOcW8ENWjx-wzpvsbgdFsSyv?width=1024&height=572&cropmode=none
  :width: 660
  :height: 369

I call this technique "Debugging the Minotour" because unlike before when we ran a new container to attach it to
another container's network namespace, we are still on the host and we use most of the host's namespaces and we choose
to use one container's mount namespace (and only the mount namespace) and another container's network namespace
(and only the network namespace). As we were creating a Minotour where the body of the Minotour is the mount namespace
of the debugger container with all of its tools and the head is the other container's network namespace which we want to
debug. To do this, we use only :code:`nsenter` and nothing else.

.. image:: https://ams03pap003files.storage.live.com/y4mWwg4TjkrinTW0umXmovn_zlsMsu0oXjQICPIiDwHHQaZkVIUHLxfPtELVVUwW09unIqiDzOqS_w0hPbh1UFt7l7rkg_IN2s2qVxWDlA2XZmxu7Z5JTNsjiEdbhTdJB1i-VqefQBJTTx39UrRNeYXqTrf3ZkCDLBP6sU532CU3R9M9NOQxod5kZLfD1QgHNlw?width=1024&height=566&cropmode=none
  :width: 660
  :height: 365

We know that we can use an executable on the host's filesystem and run it in a network namespace.
We can also choose the mount namespace and that can be the filesystem of a running container.
First we want to have a running debugger container.
`nicolaka/netshoot`_ is an excellent image to start a debugger container from. We need to run it in detached mode
(:code:`-d`) so it will run in the background (not attaching to the container's namespaces) and also in interactive mode
(:code:`-i`) so it will keep running instead of exiting immediately.

.. code:: bash

  docker run -d -i --name debug nicolaka/netshoot:v0.9

Now we need to get the sandbox key for the network namespace and since we want to debug the PHP container,
we will get the sandbox key from it. We also need something for the mount namespace of the debugger container.
This is a good time to learn that if we have an existing process, we can find all of its namespaces using a path
like this:

.. code:: text

  /proc/<PID>/ns/<NAMESPACE>

where :code:`<PID>` is the process id and :code:`<NAMESPACE>` in case of the discussed best known namespaces is one of
the followings: :code:`mnt`, :code:`net`, :code:`pid`. We could use :code:`/proc/$pid/ns/net` instead of the sandbox key,
but in this example I will keep it to demonstrate that you can do both.

.. code:: bash

  php_sandbox_key=$(docker container inspect php --format '{{ .NetworkSettings.SandboxKey }}')
  debug_pid=$(docker container inspect debug --format '{{ .State.Pid }}')

Now that we have the variables, let's use :code:`nsenter` a new way. So far we used the sandbox key only to help
the :code:`ip` command to recognize the network namespaces. Now we have to refer to it directly and :code:`nsenter`
can do that.

.. code:: bash

  sudo nsenter --net=$php_sandbox_key --mount=/proc/$debug_pid/ns/mnt ping dns.google

This way we have a ping command running, but sometimes we need to do more debugging.
The :code:`ping` command is almost always available on Linux systems, although
you can use `tshark <https://www.wireshark.org/docs/man-pages/tshark.html>`_
or `tcpdump <https://www.tcpdump.org/>`_ to see the network packets, but I prefer to use :code:`tshark`.
The following command will show us packets going through the debugger container's :code:`eth0` interface
so you can actually see the source of everything before those packets are reaching the :code:`veth*` interface
on the host. Since you can use tshark from the debugger container, you don't have to install it.
In case you have a more advanced debugger script which for some reason needs to access other namespaces on the host,
you can do that too.

.. code:: bash

  sudo nsenter --net=$php_sandbox_key --mount=/proc/$debug_pid/ns/mnt tshark -i eth0

As a final step, open a new terminal and generate some traffic on the container network.
Get the ip address of the container and use :code:`curl` to get the main page of the website in the container.

.. code:: bash

  ip=$(docker container inspect php --format '{{ .NetworkSettings.IPAddress }}')
  curl "$ip"

As a result, in the previous terminal window you should see the request packets and the response.

Testing a web-based application without internet in a container
===============================================================

Running a web browser in a net namespace on Linux (Docker CE)
-------------------------------------------------------------

If you are running Docker CE on Linux (not Docker Desktop), you can just use a web browser on your host
operating system and run it in the network namespace of a container. If the application inside is listening on
localhost, you can access it from the web browser in the same network namespace.


.. image:: https://ams03pap003files.storage.live.com/y4m6ttLxII7ZuOO9XM71cxcLPYhtAoda0zvw_av_anauoCriMR4_CzK0W3Mrmp_GNtOXY0pFYtNXIxdUqXoN6p-iGelwH-eh_zxKW4LiN5O51ROevUxhck26uAzfsonkqidFHX4onEilJw7yk5IuMhSsCoBAeA6ioEbhx30jcfihB0yFUVcurVhSeDTcda9X8UJ?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

.. code:: bash

  docker run -d --name php-networkless --network none itsziget/phar-examples:1.0
  sudo nsenter --net=/proc/$pid_networkless/ns/net curl localhost

Or sometimes you know that the frontend is safe to use, so you only want to test the backend.

.. image:: https://ams03pap003files.storage.live.com/y4mXhMjni9wwMmpFJqj3lPKJojYSac-gNBsOBnPhauY_NIlBfbyF8Pyd9oV-ldlPsedtoV5HsKNKrWa-mQyVszazCiSLG1ErUId4e9ljFoEmogLdTYHmD5Knx5GWFjMb7_q0383amuLCjSf95O5-bj2-9utVrLcORhWwirk3RH6HvJr0_R-pPTWZqdWvhfmVrP9?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

In that case you can run the container with network, but only with an "internal" network, so the host and the container
can communicate, but no traffic will be forwarded to the internet from the Docker bridge.
This way you can run your browser "on the host" and use the container's ip address instead of "localhost".

.. note:: Actually everything is running on the host. Only the isolated processes will see it differently.

You need to

- create an internal network,
- run the container using the internal network
- get the ip address of the container
- open your web browser or use curl to access the website

.. code:: bash

  docker network create internal --internal
  docker run -d --name php-internal --network internal itsziget/phar-examples:1.0
  ip_internal=$(docker container inspect php-internal --format '{{ .NetworkSettings.Networks.internal.IPAddress }}')
  curl "$ip_internal"

Since curl will not execute javascript, you can even check the generated source code, but nothing in the container will
be able to send request to the outside world except the host machine:

.. code:: bash

  docker exec php-internal ping 8.8.8.8

Running a web browser in a net namespace in a VM (Docker Desktop)
-----------------------------------------------------------------

When you start to use Docker Desktop, one of the most important facts is that your containers will run in a virtual
machine even on Linux (See: :ref:`Getting Started: Docker Desktop <getting_started_docker_desktop>`).
It means your actual host, the virtual machine and the container's will have their own "localhost".

.. image:: https://ams03pap003files.storage.live.com/y4mECX4qRmNTWbprlH3XGcvtUsLmlFzsXN8URNWhaMh0xAQggd-yqWt2jLZ1Hw-id8a9zHhRlAacKNvx_a3T7x3na3jJb6cQZYJn-7mxUn-TeHOEQjF4fmzsVdT4CJ1evgpdQxbYkPy7tXbD58XWH6Hdj_XCY4aOXyKsOWUA1cUTaB_UpM0iMc8zt4MVOapsX3p?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

The network namespaces will be in that virtual machine, so you can't just run your web browser on your
host operating system inside the network namespace.

.. image:: https://ams03pap003files.storage.live.com/y4mHdlEGf-ZLDYjXzq4C9mPSbTLfh70-KrSgGgqhE7IXgJ678siqxhjM6h3R62O1GIHqgc8ZaqXexQqDI1hDq7ejhjFEMX5skuuHUgvu49Ito3HLsfRyTlHDNhuIcMb_oE9yUdpC04oNWgRVrD3H29la6gk5G97WKp0KGYDaAFjm56gnbqMq-G6sRuHp3eKcNPB?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

You can't even run the web browser in the virtual machine (in case of Docker Desktop) since that is just a server
based on LinuxKit without GUI inside so you can't simply just use an internal network and connect to the IP address
from the browser.

.. image:: https://ams03pap003files.storage.live.com/y4mSSQPTZz89Jl3ZGS-r19g4u2tWAJwAxSFgeFW5UolTHiEG7VBRlzcTAYPSFclGmXiUHjfe6xia5kjMJmCL6h7gm9TijyJG9fTDwfTz_xNNTWK73RNxNpT5qEq1Hg6RJxEFOUguIpGbaQDpkld0QKDbuTQW0-Lp2BVnhGnlCYomOpAyI4bctjjs5XWiy0K_6Mp?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

We need a much more complex solution which requires everything that we have learnt so far and more.

- We know that our PHP app has to run in a container without internet access
- We also know that we can achieve that by using internal networks or no network at all except loopback interface.
- Since Docker Desktop runs containers in a virtual machine, we definitely need network in the PHP container
  so we can access it from the outside.
  It means we obviously need to forward a port from the host to Docker Desktop's virtual machine,
  but we have also learnt that internal networks `do not accept forwarded ports <internal_network_port_forward>`_.
- We can however run a container with only an internal network and a proxy container with an internal and a public
  network which will be accessible from the outside. This container will forward all traffic to another container
  in the internal network.
- There is a way to run a web browser in a container and you can run this container in the PHP container's
  network namespace. The problem is that you need to access the graphical interface inside the container.
- Fortunately there is also a sponsored OSS project called `linuxserver/firefox <https://hub.docker.com/r/linuxserver/firefox>`_.
  This project let's you run Firefox and a remote desktop server in the container.

How will this all look like? The following diagram illustrates it.

.. image:: https://ams03pap003files.storage.live.com/y4m1KEFbfoWny_yv1Bp1TBAqStQfTw3DjvXsy4nX-jIhH3CajaoaYesfUqHIQ2toAJQEhKCVEvssJiyo8jIBsaTFNB2yN2qMoPQLIOVQ1bPzWDFnXdoE95U0Y6_0r0rRAoMDLE_6GVVVC9V33ygw8Ot6VvXm51c5LnVy02w1a9oC_x2f2YK1n8SIXqFLZVEu10w?width=1024&height=576&cropmode=none
  :width: 660
  :height: 371

- You will use a web browser on the host as a remote desktop client to access the forwarded port of the proxy server
  on the IP address of the public network.
- The PHP container will have an internal network
- The Firefox container with the remote desktop client will use the network namespace of the PHP container
  so Firefox will not have internet access.
- The proxy server (with both internal and public network) will forward your request to the PHP container's
  network namespace to access the remote desktop server.
- The remote desktop server will stream back the screen only through the proxy server so
  the graphical interface of the containerized Firefox will appear in the web browser running on your host.
  If a harmful application tries to use JavaScript to access another website it won't be able to
  since all you can see is a picture of a web browser running in an isolated environment.

I have created a compose file which we can use to create this whole environment.

Create a project folder anywhere you like. This is mine:

.. code-block:: bash

  project_dir="$HOME/Data/projects/testprojects/netns"
  mkdir -p "$project_dir"
  cd "$project_dir"

Download the compose file from GitHub

.. code-block:: bash

  curl --output compose.yml \
       https://gist.githubusercontent.com/rimelek/91702f6e9c9e0ae75a72a42211099b63/raw/339beaf0c50790e86ab8a011ed298c250da3b7ec/compose.yml

Compose file content:

.. code-block:: yaml

  networks:
    default:
      internal: true
    public:

  services:
    php:
      image: itsziget/phar-examples:1.0

    firefox:
      network_mode: service:php
      environment:
        PUID: 1000
        PGID: 1000
        TZ: Europe/London
      shm_size: "1gb"
      image: lscr.io/linuxserver/firefox:101.0.1

    proxy:
      image: alpine/socat:1.7.4.4-r0
      command: "TCP-LISTEN:3000,fork,reuseaddr TCP:php:3000"
      ports:
        - 3000:3000
      networks:
        - default
        - public


Start the containers:

.. code-block:: bash

  docker compose up -d

If you open :code:`localhost:3000` in your browser, you will see the containerized browser and the demo application
without CSS and JavaScript since those files would be loaded from an external source and they are not available.

.. image:: https://ams03pap003files.storage.live.com/y4mf8p2GdGcbpsiRfhhoAul1AGccS-ltD0xLb1Xwwk18GT_catC9ZKsnFeRFNhydqLS8_oX8m9eYgUbbIaB6bIEQOP2ycerGxZTc1i8IbX50GLRS7ENcKh-_n6PVgAb2CC0yQ9nzKFLwSxPN8y0hm6l790oRmcQT9JdjRpZ4Oeue9bvWg4-wooi_anUnuFKAe3C?width=1024&height=608&cropmode=none
  :width: 660
  :height: 392

Now that you know it is trying to load CSS and some harmless JavaScripts, you can run it with a public network

.. code-block:: bash

  docker run -d --name php-internet -p 8080:80  itsziget/phar-examples:1.0

and open it in an other tab on port 8080.

.. image:: https://ams03pap003files.storage.live.com/y4mJmFWwgDzMO3t3sTv6E7iqACDdmxsKyd5HKz45U6xXlaP6dmnhCV-iN3fEAT6ZFY5JGXvOlXCj1AxyUnDDkW5WEUBw_qIDO1NiXQ4NO5uJfdkUdbHcWLQjYwH7g1kVRhUZ29BbmyRC1JZnRO2wdZhOAN7JgxIc35xSg1lE1kvJeF4VJc5VkmsJi9lINq1l1UJ?width=1024&height=596&cropmode=none
  :width: 660
  :height: 392

Used sources
============

- https://www.redhat.com/sysadmin/net-namespaces
- https://serverfault.com/a/704717
- https://serverfault.com/questions/1007562/linux-networking-bridge-with-veths-not-able-to-send-outbound-packets
- https://github.com/p8952/bocker/blob/master/bocker
- https://collabnix.com/a-beginners-guide-to-docker-networking/


Recommended similar tutorials
=============================

- https://iximiuz.com/en/posts/container-networking-is-simple/
