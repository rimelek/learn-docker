============================================
Kernel namespaces and containers in practice
============================================

Linux Kernel Namespaces in general
==================================

Let's start with a simple example so we can understand why namespaces are useful.

.. image:: https://ams03pap003files.storage.live.com/y4m1n8TZUq1S6a4wCgpfkei-rnJHsvtcNULyw4cVjsPVblZo5ahi9pLCXYmmBQwH-mGePpXOXSjjwyIoOSdD8jZDmb-evAaciWiSxOankmwxfzspFKhF_hcCXHgbuZf9uIQqgJTHjW-PQaml-8qZhkEEWYiXki865ymC_MHzzgSTlLcwBBj2t7ghGfKf48i02pd?width=660&height=371&cropmode=none
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

.. image:: https://ams03pap003files.storage.live.com/y4mzjrcPyuVn9OD1zYwNmEBN2pyox7VG1FQ_RmxFettn51tEtHuaAJUiHdC5cgro8cvuwTu4E4rlQMky1I7qCMklRt4o2F0OB-rVuihnArI3HcCO-yVj8jIXJptP47avmYzZAE4kGftN0LeCBK_xu1Vz_ckFq0GmP2BBL9Aw_cjfFyvOTSw2sYxoR8VL-wtLjAw?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

This is not always enough. Sometimes you don't want a specific process to see other processes on the host.
In this case you can use the PID namespace so the PHP process will not be able to see other processes on the host,
only the processes in the same PID namespace. Since on Linux there is always a process with the process ID 1 (PID 1),
for any process in the network namespace, PHP will have PID 1. For any process outside of that PID namespace,
PHP will have a larger process ID like 2324.

.. image:: https://ams03pap003files.storage.live.com/y4mxFENT6Q7HHAuAMs8cMVMbmDPPAXSEP8RW196gW0iUp9DCO0LqQLvkEI76UEMlzk6Rcaua1kBdZ16YqMlMGwy2r9yBPTyOikhfT7OSk_DSfcZdhJTsGAaJggTTSjS51UH69UNdBctkJdyBEYZxzZuhzhcmlvGZk-SxyJ07zSGkEtpnOMWoind3nAbU3xZvYjN?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

And finally we arrived to the network namespace. Network namespace can hide network interfaces from processes
in the namespace. The network namespace can have its own IP address, but it will not necessarily have one.
Thanks to the network namespace, PHP will only be able to listen its own IP address in a Docker network.

.. image:: https://ams03pap003files.storage.live.com/y4m56sZ2NrTbPALYdSQalVVVOUuS-X54NrBLeeYMKNXhHGbr7QjW9y1YX5qzFDSgRm0Sw3YlI65Fge7R3EpdeircZLwS2cXiqVpEf7ml9iSidaDmrELqFktZF3wqjhE4fhwIm1-zeKhpUsCnFi_SlRsHkRtxgzgfL7qaK6OyHR1ou3l1lXKjQ8mHDwTkGfcoK-C?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

These namespaces are independent and not owned by the PHP process. Any other process could be added to these namespaces,
and you don't need to run those processes in each namespace.

.. image:: https://ams03pap003files.storage.live.com/y4mtcvQh0D9f6yXwWqGuKJt7FEtfqYE5Ys-Mw0ke22z26QotmvwzYGeX_CjH-ltZi5CLVX6bG2h8eXkbFfp4PCBMSCi-jQKZvA66Ta5EkHdiiuoU9SE4ouQyt4w_rWTu293SG6mqBDL3bXIu0IFeBoHwbiH6CGe21b4YwPiahAgIy0Ef3AVWe4iZl471yi9LY2Z?width=660&height=371&cropmode=none
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

.. image:: https://ams03pap003files.storage.live.com/y4mFhcL1bVgyENw2zODj83Dq1Do9pAtW1Vu_LJyWvZX6h0ZKJHBiR1pJPZC9OnxHcM8S2h3wSczzH5i78a66BQ0FneBmaCs3RnroUGpRQq7-7qRf3NbdZREZUeRcrJzrjsyLpIjpQHleA4sTUWByNPgmvXYHsbZ3oJZKsNktcCVWqqFKjuC3ApTgmwhUy7KBLiF?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

This interface could be "eth0", although recently it is more likely to be something like "enp1s0" or "eno1".
The point is that traffic routed through this interface can leave the host machine. The container needs
its own network interface which is connected to another outside of the container on the host. The name of the interface
on the host will start with "veth" followed by a hash.

.. image:: https://ams03pap003files.storage.live.com/y4mQMfMohZTsJLikmtdvp-yoAVD4AyXmudA8rLFTkY_vfBwVQMl3Rv3zIlbNHi9lwMMuitYSDXTOWdcpb6nyvQFkhI7bSTkuYyI5kHqZTN9jjsnSgWpGjQOlFIdcmSnBxJ6QY2yf2U54lAErzJ2MVJ9zFXC8u36_pCe-Ejd4qO2zjRx05KmMR0XyHLETQyN3wt8?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

The veth interface will not have IP address. It could have, but Docker uses a different way so containers in the same
Docker network can communicate with each other. There will be a bridge network between the veth interface and eth0.
The the bridge of the default Docker network is "docker0".

.. image:: https://ams03pap003files.storage.live.com/y4majKY-A1ONQ4ymytVBW1-7ZXQyw1Q8DWGhqd1Pku8ofvzee8cgqkkjAtZDJ1SG5g4KFROeTswcxTglBK_4XEmktQtxvxnx8Eg5JJJKuYEOatgDeRUykZro2MbiVPogNfjg8EmLZeHQXQ9r_-BcPc5tMfbMggRVsLJipqb2NktZszCvxvMlzqk3tMOD0xUq3R2?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

This bridge will have an IP address which will also be the gateway for each container in the default Docker network.
Since this is on the host outside of the network namespace, any process running on the host could listen on this IP
address so processes running inside the container could use this IP to access a webservice listening on it.

Sometimes you don't want a containerized process to access the internet, because you don't trust an application
and you want to test or run in without internet access for security reasons indefinitely. This is when
"internal networks" can help.

.. image:: https://ams03pap003files.storage.live.com/y4mppUzYKGFL3m29qkojJsrZ04p08epKXHllkDNM1T_mfW8KyEZ9MFmklxHqUrSWfo66V0YfA4XWalAHO5jTW76fuNjiwaM_Rea1VIUOZOTBmmfJFKqIBqPKat9Ytnoq6AnIqpM5icNg6jjPZ44Y2HCn6xeppNz4vmAUKiqz0lYOvQwofrUkKUOe-zeXrqMvtEZ?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

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

.. image:: https://ams03pap003files.storage.live.com/y4mrSPlwK5dG8gpAqcK-T4zOEgFpZrvMclsrhkRSEIYzJzMcoWV1Xm79u8vqyaoHyhBI83oTkwvCqN5a6F7qD0vHix4qK9jZXZ3ry3n3_JIfb4-F4mrPfDwdkqxraMdblvCbdtCyFZS47jiYIJy8LeWQnFuBNWKTizWnihSPEwUTtv8A4cZEw55wigmtbpJyP4X?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

If the web application is listening on port 80 on localhost, a web browser outside of the container will not be
able to access it, since it has a different localhost. The same is true when for example a database server
is running on the host listening on port 3306 on localhost. The PHP process inside the container
will not be able to reach it.

.. image:: https://ams03pap003files.storage.live.com/y4mfY8MswymXiqlxXUWUc90hHvRaSDOeqODcvK64ssgsNLpAh8xKwxZh4uGM3wpBZgJNjr5JaVYaqa3npDIQ5D-3NgGonwgGt4QE3KsgySwW4n7tY6cKzDlQaAfJyl-ARTRnlorF0lvGNhfhSLVZhKRCUwxS2DzBf1IcwRkpqZ9dXLCnlkJyp5v4AM85ajyG8xH?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

The reason is the network namespace so you could just run the container in host network mode

.. code:: bash

  docker run -d --name php-hostnet --network host itsziget/phar-examples:1.0

which means you just don't get the network isolation. The host network mode does not mean that you are using
a special Docker network. It only means you don't want the container to have its own network namespace.

Of course we wanted to have the network isolation and we want to keep it. The other solution is running another
container which will use the same network namespace.

.. image:: https://ams03pap003files.storage.live.com/y4m73QYpsCMLY_5zzZwYye7Vr9mSh4YB1BMmuG7Tl0i_vm6fu2R9GEB8m0HEc20FsWBDOS2TuW-TlWXphPcYq1wrQHEnN7A2RNBFULDC62TmnPnzop3jTrbMkO0tPtLoO-4vcqPjVctPAKNUMUqu02CX-0KqufP3Ghcq0SMSDpTjjVfsR25_9xZ3wDQhhikV11E?width=660&height=371&cropmode=none
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

"ip" netns" to create new network namespaces
--------------------------------------------

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

The output will be

.. code:: text

  1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

As you can see this new network namespace doesn't even have a loopback IP address so basically
it doesn't have "localhost". It shows us that a network namespace does not give us a fully configured
private network, it only gives us the network isolation. Now that we know it it is not surprising
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

.. image:: https://ams03pap003files.storage.live.com/y4mbufvZdt6vshWKx-Kj1MXkOxlAZPhaViscJpKdqIG27H8QhKw4Nprd5tqpYRGppDDIjkj3jRBlYWAfdbl5enP2dYold3sN-Akchx8cT-7043rfEh07Fl1n4dH9KZpPIN5dCg0vh85fezDbqBuim9ff3VGIznDMHXFT5bH4M9bTeAD034WCXxD2P7-EnzaJO4E?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

We ran the ping command only in the network namespace of the container, which means the configuration files
that are supposed to control how name resolution works are loaded from the host. My host was an Ubuntu 20.04 LTS
virtual machine created by `Multipass <https://multipass.run/>`_. By default, the IP address of the nameserver
is `127.0.0.53`. Remember, that this IP address belongs to the loopback interface which is different in each
network namespace. In the network namespace of our PHP container there is no service listening on this IP address.

Solution 1: Change the configuration of on the host
+++++++++++++++++++++++++++++++++++++++++++++++++++

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

Debugging of the Minotour
-------------------------

.. image:: https://ams03pap003files.storage.live.com/y4mr1D0jGmHwCggOST2qxXX06T3N0wpYgBEwKj8bvoD_ZkqvlcEQQZ5fx6RjAquKsid1VUq-gOF41fFLlFIMAyQCVy3msfDSS9R5ZfTV684EXRHIb9AGgxky1bMw3WliOWC9DwZzy5ykAoLG5jENJ2QJ5E1iT-fauWhuaXySqBzewoJbcWKYq96kw9NJrrTmQwQ?width=660&height=371&cropmode=none
  :width: 660
  :height: 371

I call this technique "Debugging of the Minotour" because unlike before when we ran a new container to attach it to an
other containers network namespace, we are still on the host and we use most of the host's namespaces and we choose
to use one container's mount namespace (and only the mount namespace) and another container's network namespace
(and only the network namespace). As we were creating a Minotour where the body of the Minotour is the mount namespace
of the debugger container with all of its tools and the head is the other containers network namespace which we want to
debug. To do this, we use only :code:`nsenter` and nothing else.

.. image:: https://ams03pap003files.storage.live.com/y4mWwg4TjkrinTW0umXmovn_zlsMsu0oXjQICPIiDwHHQaZkVIUHLxfPtELVVUwW09unIqiDzOqS_w0hPbh1UFt7l7rkg_IN2s2qVxWDlA2XZmxu7Z5JTNsjiEdbhTdJB1i-VqefQBJTTx39UrRNeYXqTrf3ZkCDLBP6sU532CU3R9M9NOQxod5kZLfD1QgHNlw?width=660&height=365&cropmode=none
  :width: 660
  :height: 365

.. code:: bash

  docker run -d -i --name debug nicolaka/netshoot

.. code:: bash

  php_sandbox_key=$(docker container inspect php --format '{{ .NetworkSettings.SandboxKey }}')
  debug_pid=$(docker container inspect debug --format '{{ .State.Pid }}')

.. code:: bash

  sudo nsenter --net=$php_sandbox_key --mount=/proc/$debug_pid/ns/mnt ping dns.google

.. code:: bash

  sudo nsenter --net=$php_sandbox_key --mount=/proc/$debug_pid/ns/mnt tshark -i eth0

.. code:: bash

  ip=$(docker container inspect php --format '{{ .NetworkSettings.IPAddress }}')
  curl "$ip"




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
