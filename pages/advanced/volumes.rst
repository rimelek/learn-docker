.. _Docker forum: https://forums.docker.com
.. _daemon configuration: https://docs.docker.com/engine/reference/commandline/dockerd/#on-linux
.. _rootless Docker: https://docs.docker.com/engine/security/rootless/
.. _Use Compose watch: https://docs.docker.com/compose/file-watch/
.. _Volume-only Compose projects: https://dev.to/rimelek/docker-compose-volumes-volume-only-projects-and-init-containers-5468
.. _Docker Hub: https://hub.docker.com/

:og:image: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133448&authkey=%21AC_sk0Z8Qkg_XdU&width=1024
:og:description: Learn about Docker volumes, where they are and how you can access them.

.. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133448&authkey=%21AC_sk0Z8Qkg_XdU&width=1024
  :width: 660
  :height: 371

===============================
Everything about Docker volumes
===============================

Intro
=====

"Where are the Docker volumes?"
This question comes up a lot on the `Docker forum`_.
There is no problem with curiosity, but this is usually asked when someone wants to
edit or at least read files directly on the volume from a terminal or an IDE,
but not through a container. So I must start with a statement:

.. important::

  You should never handle files on a volume directly without entering a container,
  unless there is an emergency, and even then, only at your own risk.

Why I am saying it, you will understand if you read the next sections.
Although the original goal with this tutorial was to explain where the volumes are,
it is hard to talk about it without understanding what the volumes are
and what different options you have when using volumes.
As a result of that, by reading this tutorial, you can learn basically
everything about the local volumes, but you can also
search for volume plugins on `Docker Hub`_.

.. _docker_data_root:

Where does Docker store data?
=============================

Before we talk about the location of volumes, we first have to talk about
the location of all data that Docker handles.
When I say "Docker", I usually mean "Docker CE".

:ref:`Docker CE <concept_docker_ce>` is the community edition of Docker and can run
directly on Linux. It has a data root directory, which is the following by default:

.. code-block:: text

  /var/lib/docker

You can change it in the `daemon configuration`_, so if it is changed on your system,
you will need to replace this folder in the examples I show.
To find out what the data root is, run the following command:

.. code-block:: bash

  docker info --format '{{ .DockerRootDir }}'

In case of Docker Desktop of course, you will always have a virtual machine,
so the path you get from the above command will be in the virtual machine.

What is a Docker volume?
========================

For historical reasons, the concept of volumes can be confusing.
There is a `page in the documentation <https://docs.docker.com/storage/volumes/>`_
which describes what volumes are, but when you see a Compose file or a docker run command,
you see two types of volumes, but only one of them is actually a volume.

Example Compose file:

.. code-block:: yaml

  services:
    server:
      image: httpd:2.4
      volumes:
        - ./docroot:/usr/local/apache2/htdocs

Did I just define a volume?
No. It is a `bind mount <https://docs.docker.com/storage/bind-mounts/>`_.
Let's just use the long syntax:

.. code-block:: yaml

  services:
    server:
      image: httpd:2.4
      volumes:
        - type: bind
          source: ./docroot
          target: /usr/local/apache2/htdocs

The "volumes" section should have been "storage" or "mounts" to be more clear.
In fact, the "docker run" command supports the :code:`--mount` option in addition to
:code:`-v` and :code:`--volume`, and only :code:`--mount` supports the type parameter
to directly choose between volume and bind mount.

Then what do we call a volume? Let's start with answering another question.
What do we not call a volume? A file can never be a volume. A volume is always a
directory, and it is a directory which is created by Docker and handled by Docker
throughout the entire lifetime of the volume. The main purpose of a volume is
to populate it with the content of the directory to which you mount it
in the container. That's not the case with bind mounts. Bind mounts just
completely override the content of the mount point in the container, but at least
you can choose where you want to mount it from.

You should also know that you can disable copying data from the container to your
volume and use it as a simple bind mount, except that Docker creates it in the Docker
data root, and when you delete the volume after you wrote something on it, you will lose
the data.

.. code-block:: yaml

  volumes:
    docroot:

  services:
    server:
      image: httpd:2.4
      volumes:
        - type: volume
          source: docroot
          target: /usr/local/apache2/htdocs
          volume:
            nocopy: true

You can find this and other parameters in the
`documentation of volumes in a compose file <https://docs.docker.com/compose/compose-file/05-services/#volumes>`_.
Scroll down to the "Long syntax" to read about "nocopy".

.. _custom_volume_path:

Custom volume path
==================

Custom volume path overview
---------------------------

There is indeed a special kind of volume which seems to mix bind mounts and volumes.
The following example will assume you are using Docker CE on Linux.

.. code-block:: bash

  volume_name="test-volume"
  source="$PWD/$volume_name"

  mkdir -p "$volume_name"
  docker volume create "$volume_name" \
    --driver "local" \
    --opt "type=none" \
    --opt "device=$source" \
    --opt "o=bind"

Okay, so you created a volume and you also specified where the source directory is (device),
and you specified that it is a bind mount.
Don't worry, you find it confusing because it is confusing.
:code:`o=bind` doesn't mean that you will bind mount a directory into the container,
which will always happen,
but that you will bind mount the directory to the path where Docker would have
created the volume if you didn't define the source.

This is basically the same what you would do on Linux with the :code:`mount` command:

.. code-block:: bash

  mount -o bind source/ target/

Without :code:`-o bind` the first argument must be a block device.
This is why we use the "device" parameter, even though we mount a folder.

This is one way to know where the Docker volume is.

.. note::

  Even the the above example assumed Linux, custom volume path
  would work on other operating systems as well, since Docker
  Desktop would mount the required path into the virtual machine.

Let's just test if it works and inspect the volume:

.. code-block:: bash

  docker volume inspect test-volume

You will get a json like this:

.. code-block:: json

  [
      {
          "CreatedAt": "2024-01-05T00:55:15Z",
          "Driver": "local",
          "Labels": {},
          "Mountpoint": "/var/lib/docker/volumes/test-volume/_data",
          "Name": "test-volume",
          "Options": {
              "device": "/home/ta/test-volume",
              "o": "bind",
              "type": "none"
          },
          "Scope": "local"
      }
  ]

The "Mountpoint" field in the json is not the path in a container, but the path where
the specified device should be mounted at. In our case, the device is actually a directory.
So let's see the content of the mount point:

.. code-block:: bash

  sudo ls -la $(docker volume inspect test-volume --format '{{ .Mountpoint }}')

You can also check the content of the source directory:

.. code-block:: bash

  ls -la test-volume/

Of course, both are empty as we have no container yet.
How would Docker know what the content should be?
As we already learned it, we need to mount the volume into a container
to populate the volume.

.. code-block:: bash

  docker run \
    -d --name test-container \
    -v test-volume:/usr/local/apache2/htdocs \
    httpd:2.4

Check the content in the container:

.. code-block:: bash

  docker exec test-container ls -lai /usr/local/apache2/htdocs/

Output:

.. code-block:: text

  total 16
   256115 drwxr-xr-x 2 root     root     4096 Jan  5 00:33 .
  5112515 drwxr-xr-x 1 www-data www-data 4096 Apr 12  2023 ..
   256139 -rw-r--r-- 1      501 staff      45 Jun 11  2007 index.html

Notice that we added the flag "i" to the "ls" command so we can see the inode number,
which identifies the files and directories on the filesystem in the first column.

Check the directory created by Docker:

.. code-block:: bash

  sudo ls -lai $(docker volume inspect test-volume --format '{{ .Mountpoint }}')

.. code-block:: text

  256115 drwxr-xr-x 2 root root  4096 Jan  5 00:33 .
  392833 drwx-----x 3 root root  4096 Jan  5 00:55 ..
  256139 -rw-r--r-- 1  501 staff   45 Jun 11  2007 index.html

As you can see, only the parent directory is different, so we indeed see the same files
in the container and in the directory created by Docker.
Now let's check our source directory.

.. code-block:: bash

  ls -lai test-volume/

Output:

.. code-block:: text

  total 12
  256115 drwxr-xr-x  2 root root  4096 Jan  5 00:33 .
  255512 drwxr-xr-x 11 ta   ta    4096 Jan  5 00:32 ..
  256139 -rw-r--r--  1  501 staff   45 Jun 11  2007 index.html

Again, the same files, except the parent.
We confirmed, that we could create an empty volume directory,
we could populate it when we started a container and mounted the volume,
and the files appeared where Docker creates volumes. Now let's check one more thing.
Since this is a special volume where we defined some parameters,
there is an :code:`opts.json` right next to :code:`_data`

.. code-block:: bash

  sudo cat "$(dirname "$(docker volume inspect test-volume --format '{{ .Mountpoint }}')")"/opts.json

Output:

.. code-block:: json

  {"MountType":"none","MountOpts":"bind","MountDevice":"/home/ta/test-volume","Quota":{"Size":0}}

Now remove the test container:

.. code-block:: bash

  docker container rm -f test-container

Check the directory created by Docker:

.. code-block:: bash

  sudo ls -lai $(docker volume inspect test-volume --format '{{ .Mountpoint }}')

It is empty now.

.. code-block:: text

  392834 drwxr-xr-x 2 root root 4096 Jan  5 00:55 .
  392833 drwx-----x 3 root root 4096 Jan  5 00:55 ..

And notice that even the inode has changed, not just the content disappeared.
On the other hand, the directory we created is untouched and you can still find the
:code:`index.html` there.

Avoid accidental data loss on volumes
-------------------------------------

Let me show you an example using Docker Compose. The compose file would be the following:

.. code-block:: yaml

  volumes:
    docroot:
      driver: local
      driver_opts:
        type: none
        device: ./docroot
        o: bind

  services:
    httpd:
      image: httpd:2.4
      volumes:
        - type: volume
          source: docroot
          target: /usr/local/apache2/htdocs

You can populate :code:`./docroot` in the project folder by running

.. code-block:: bash

  docker compose up -d

You will then find :code:`index.html` in the docroot folder.
You probably know that you can delete a compose project by running
:code:`docker compose down`, and delete the volumes too by
passing the flag :code:`-v`.

.. code-block:: bash

  docker compose down -v

You can run it, and the volume will be destroyed, but not the content of the
already populated "docroot" folder. It happens, because the folder
which is managed by Docker in the Docker data root does not physically
have the content. So the one that was managed by Docker could be
safely removed, but it didn't delete your data.

Docker CE volumes on Linux
==========================

This question seems to be already answered in the previous sections, but let's
evaluate what we learned and add some more details.

So you can find the local default volumes under :code:`/var/lib/docker/volumes`
if you didn't change the :ref:`data root <docker_data_root>`.
For the sake of simplicity of the commands, I will keep using the default path.

The Docker data root is not accessible by normal users, only by administrators.
Run the following command:

.. code-block:: bash

  sudo ls -la /var/lib/docker/volumes

You will see something like this:

.. code-block:: text

  total 140
  drwx-----x 23 root root  4096 Jan  5 00:55 .
  drwx--x--- 13 root root  4096 Dec 10 14:27 ..
  drwx-----x  3 root root  4096 Jan 25  2023 0c5f9867e761f6df0d3ea9411434d607bb414a69a14b3f240f7bb0ffb85f0543
  drwx-----x  3 root root  4096 Sep 19 13:15 1c963fb485fbbd5ce64c6513186f2bc30169322a63154c06600dd3037ba1749a
  ...
  drwx-----x  3 root root  4096 Jan  5  2023 apps_cache
  brw-------  1 root root  8, 1 Dec 10 14:27 backingFsBlockDev
  -rw-------  1 root root 65536 Jan  5 00:55 metadata.db

These are the names of the volumes and two additional special files.

- backingFsBlockDev
- metadata.db

We are not going to discuss it in more details. All you need to know at this point is
that this is where the volume folders are. Each folder has a sub-folder called "_data"
where the actual data is, and there could be an :code:`opts.json` with metadata next to the
"_data" folder.

.. note::

  When you use `rootless Docker`_, the Docker data root will be in your user's home.

  .. code-block:: text

    $HOME/.local/share/docker

Docker Desktop volumes
======================

Docker Desktop volumes are different depending on the operating system
and whether you want to run Linux containers or Windows containers.

Docker Desktop always runs a virtual machine
for Linux containers and runs Docker CE in it in a quite complicated way,
so your volumes will be in the virtual machine too. Because of that fact
when you want to access the volumes, you either have to find a way to run a shell
in the virtual machine, or find a way to share the filesystem on the network
and use your filebrowser, IDE or terminal on the host.

Parts of what I show here and more can be found in my presentation which
I gave on the 6th Docker Community All-Hands. Tyler Charboneau wrote a
`blog post <https://www.docker.com/blog/how-to-fix-and-debug-docker-containers-like-a-superhero/>`_
about it, but you can also
`find the video <https://www.youtube.com/watch?v=8zVOCnfkycY>`_ in the blog post.

Docker Desktop volumes on macOS
-------------------------------

On macOS, you can only run Linux containers and there is no such thing as
macOS container yet (2024. january).

You can get to the volumes folder by running the following command:

.. code-block:: bash

  docker run --rm -it --privileged --pid host ubuntu:22.04 \
    nsenter --all -t 1 \
      sh -c 'cd /var/lib/docker/volumes && sh'

Or just simply mount that folder to a container:

.. code-block:: bash

  docker run --rm -it \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    --workdir /var/lib/docker/volumes \
    ubuntu:22.04 \
    bash

You can also run an NFS server in a container that mounts the volumes
so you can mount the remote fileshare on the host.
The following :code:`compose.yml` file can be used to run the NFS server:

.. code-block:: yaml

  services:

    nfs-server:
      image: openebs/nfs-server-alpine:0.11.0
      volumes:
         - /var/lib/docker/volumes:/mnt/nfs
      environment:
        SHARED_DIRECTORY: /mnt/nfs
        SYNC: sync
        FILEPERMISSIONS_UID: 0
        FILEPERMISSIONS_GID: 0
        FILEPERMISSIONS_MODE: "0755"
      privileged: true
      ports:
        - 127.0.0.1:2049:2049/tcp
        - 127.0.0.1:2049:2049/udp

Start the server:

.. code-block:: bash

  docker compose up -d

Create the mount point on the host:

.. code-block:: bash

  sudo mkdir -p /var/lib/docker/volumes
  sudo chmod 0700 /var/lib/docker

Mount the base directory of volumes:

.. code-block:: bash

  sudo mount -o vers=4 -t nfs 127.0.0.1:/ /var/lib/docker/volumes

And list the content:

.. code-block:: bash

  sudo ls -l /var/lib/docker/volumes

Docker Desktop volumes on Windows
---------------------------------

Docker Desktop on Windows allows you to switch between Linux containers
and Windows containers.

.. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133432&authkey=%21AG_OMIggB6CmAJI&width=687&height=372
  :width: 330
  :height: 178

.. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133431&authkey=%21AOgI2KQ2PKdvU4A&width=762&height=372
  :width: 330
  :height: 161

To find out which one you are using,
run the following command:

.. code-block:: powershell

  docker info --format '{{ .OSType }}'

If it returns "windows", you are using Windows containers, and if it returns
"linux", you are using Linux containers.

Linux containers
++++++++++++++++

Since Linux containers always require a virtual machine, you will have
your volumes in the virtual machine the same way as you would on macOS.
The difference is how you can access them. A common way is through
a Docker container. Usually I would run the following command.

.. code-block:: powershell

  docker run --rm -it --privileged --pid host ubuntu:22.04 `
    nsenter --all -t 1 `
      sh -c 'cd /var/lib/docker/volumes && sh'

But if you have an older kernel in WSL2 which doesn't support the time namespace,
you can get an error message like:

.. code-block:: text

  nsenter: cannot open /proc/1/ns/time: No such file or directory

If that happens, make sure you have the latest kernel in WSL2.
If you built a custom kernel, you may need to rebuild it from a new
version.

If you can't update the kernel yet, exclude the time namespace,
and run the following command:

.. code-block:: powershell

  docker run --rm -it --privileged --pid host ubuntu:22.04 `
    nsenter -m -n -p -u -t 1 `
      sh -c 'cd /var/lib/docker/volumes && sh'

You can simply mount the base directory in a container
the same way as we could on macOS:

.. code-block:: powershell

  docker run --rm -it `
    -v /var/lib/docker/volumes:/var/lib/docker/volumes `
    --workdir /var/lib/docker/volumes `
    ubuntu:22.04 `
    bash

We don't need to run a server in a container to share the volumes,
since it works out of the box in WSL2. You can just open the Windows
explorer and go to

.. code-block:: text

  \\wsl.localhost\docker-desktop-data\data\docker\volumes

.. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133430&authkey=%21AD5cDeb5_HcLF2M&width=660
  :width: 660
  :height: 235

.. warning::

  WSL2 let's you edit files more easily even if the files are owned by root
  on the volume, so do it at your own risk.
  My recommendation is using it only for debugging.

Windows Containers
++++++++++++++++++

Windows containers can mount their volumes from the host.
Let's create a volume

.. code-block:: powershell

  docker volume create windows-volume

Inspect the volume:

.. code-block::: powershell

  docker volume inspect windows-volume

You will get something like this:

.. code-block:: json

  [
      {
          "CreatedAt": "2024-01-06T16:27:03+01:00",
          "Driver": "local",
          "Labels": null,
          "Mountpoint": "C:\\ProgramData\\Docker\\volumes\\windows-volume\\_data",
          "Name": "windows-volume",
          "Options": null,
          "Scope": "local"
      }
  ]

So now you got the volume path on Windows in the "Mountpoint" field,
but you don't have access to, it unless you are Administrator.
The following command works only from Powershell run as Administrator

.. code-block:: powershell

  cd $(docker volume inspect windows-volume --format '{{ .Mountpoint }}')

If you want to access it from Windows Explorer, you can first go to

.. code-block::

  C:\ProgramData

.. note::

  This folder is hidden by default, so if you want to open it, just type
  the path manually in the navigation bar, or enable hidden folders
  on Windows 11 (works differently on older Windows):

  .. code-block:: text

    Menu bar » View » Show » Hidden Items

  .. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133427&authkey=%21APhiCiUQGq72UQM&width=660
    :width: 660
    :height: 456

Then try to open the folder called "Docker" which gives you a prompt
to ask for permission to access to folder.

.. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133428&authkey=%21AKUGZd-hYWHwoqg&width=660
  :width: 660
  :height: 368

and then try to open the folder called "volumes"
which will do the same.

.. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133429&authkey=%21AALcQVxwylnJ_kc&width=660
  :width: 660
  :height: 435

After that you can open any Windows container volume from Windows explorer.

Docker Desktop volumes on Linux
-------------------------------

On Windows, you could have Linux containers and Window containers,
so you had to switch between them.
On Linux, you can install Docker CE in rootful and rootless mode,
and you can also install Docker Desktop. These are 3 different
and separate Docker installations and you can switch between them
by changing context or logging in as a different user.

You can check the existing contexts by running the following command:

.. code-block:: bash

  docker context ls

If you have Docker CE installed on your Linux, and you are logged
in as a user who installed the rootless Docker,
and you also have Docker Desktop installed, you can see at least the
following three contexts:

.. code-block:: text

  NAME                TYPE                DESCRIPTION                               DOCKER ENDPOINT                                       KUBERNETES ENDPOINT   ORCHESTRATOR
  default             moby                Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
  desktop-linux *     moby                Docker Desktop                            unix:///home/ta/.docker/desktop/docker.sock
  rootless            moby                Rootless mode                             unix:///run/user/1000/docker.sock

In order to use Docker Desktop, you need to switch to the context
called "desktop-linux".

.. code-block:: bash

  docker context use desktop-linux

.. important::

  The default is usually rootful Docker CE and the other too are obvious.
  Only the rootful Docker CE needs to run as root, so if you want to
  interact with Docker Desktop, don't make the mistake of running the docker commands
  with sudo:

  .. code-block:: bash

    sudo docker context ls

  .. code-block:: text

    NAME                TYPE                DESCRIPTION                               DOCKER ENDPOINT               KUBERNETES ENDPOINT   ORCHESTRATOR
    default *           moby                Current DOCKER_HOST based configuration   unix:///var/run/docker.sock

In terms of accessing volumes, Docker Desktop works similarly on
macOS and Linux, so you have the following options:

Run a shell in the virtual machine using nsenter:

.. code-block:: bash

  docker run --rm -it --privileged --pid host ubuntu:22.04 \
    nsenter --all -t 1 \
      sh -c 'cd /var/lib/docker/volumes && sh'

Or just simply mount that folder to a container:

.. code-block:: bash

  docker run --rm -it \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    --workdir /var/lib/docker/volumes \
    ubuntu:22.04 \
    bash

And of course, you can use the nfs server compose project with
the following :code:`compose.yml`

.. code-block:: yaml

  services:
    nfs-server:
      image: openebs/nfs-server-alpine:0.11.0
      volumes:
         - /var/lib/docker/volumes:/mnt/nfs
      environment:
        SHARED_DIRECTORY: /mnt/nfs
        SYNC: sync
        FILEPERMISSIONS_UID: 0
        FILEPERMISSIONS_GID: 0
        FILEPERMISSIONS_MODE: "0755"
      privileged: true
      ports:
        - 127.0.0.1:2049:2049/tcp
        - 127.0.0.1:2049:2049/udp

and prepare the mount point. Remember, you can have Docker CE running as root,
which means :code:`/var/lib/docker` probably exists, so let's create the mount point
as :code:`/var/lib/docker-desktop/volumes`:

.. code-block:: bash

  sudo mkdir -p /var/lib/docker-desktop/volumes
  sudo chmod 0700 /var/lib/docker-desktop

And mount it:

.. code-block:: bash

  sudo mount -o vers=4 -t nfs 127.0.0.1:/ /var/lib/docker-desktop/volumes

And check the content:

.. code-block:: bash

  sudo ls -l /var/lib/docker-desktop/volumes

You could ask why we mount the volumes into a folder on the host,
which requires sudo if the docker commands don't.
The reason is that you will need sudo to use the mount command,
so it shouldn't be a problem to access the volumes as root.

Editing files on volumes
========================

The danger of editing volume contents outside a container
---------------------------------------------------------

Now you know how you can find out where the volumes are.
You also know how you can create a volume with a custom path,
even if you are using Docker Desktop, which creates the default
volumes inside a virtual machine.

But most of you wanted to know where the volumes were to edit the files.

.. danger::

  Any operation inside the Docker data root is dangerous,
  and can break your Docker completely, or cause problems
  that you don't immediately recognize, so you should never
  edit files without mounting the volume into a container,
  except if you defined a :ref:`custom volume path <custom_volume_path>`
  so you don't have to go into the Docker data root.

  Even if you defined a custom path, we are still talking about
  a volume, which will be mounted into a container,
  in which the files can be accessed by a process which
  requires specific ownership and permissions. By editing
  the files from the host, you can accidentally change the permission
  or the owner making it inaccessible for the process in the container.

Even though I don't recommend it, I understand that sometimes
we want to play with our environment to learn more about,
but we still have to try to find a less risky way to do it.

You know where the volumes are, and you can edit the files
with a text editor from command line or even from the graphical
interface. One problem on Linux and macOS could be setting
the proper permissions so you can edit the files even
if you are not root.
Discussing permissions could be another tutorial,
but this is one reason why we have to try to separate the data
managed by a process in a Docker container from the source code
or any files that requires an interactive user.
Just think of an application that is not running in a container,
but the files still have to be owned by another user.
An example could be a webserver, where the files has to be
owned by a user or group so the webserver has access to the files,
while you still should be able to upload files.

View and Edit files through Docker Desktop
------------------------------------------

Docker Desktop let's you browse files from the GUI,
which is great for debugging, but I don't recommend it for editing files,
even though Docker Desktop makes that possible too.
Let's see why I am saying it.

Open the Containers tab of Docker Desktop.

.. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133436&authkey=%21ADM4u1wAPqL8rmU&width=660
  :width: 660
  :height: 254

Click on the three dots in the line of the container in which you want to browse files

.. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133437&authkey=%21ADNIjONXytcFUHs&width=660
  :width: 660
  :height: 254

Go to a file that you want to edit

.. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133438&authkey=%21ACErzlwcIzzwuDI&width=660
  :width: 660
  :height: 254

.. note::

  Notice that Docker Desktop shows you whether the files are modified
  on the container's filesystem, or you see a file on a volume.

Right click on the file and select "Edit file".

Before you do anything, run a test container:

.. code-block:: bash

  docker run -d --name httpd -v httpd_docroot:/usr/local/apache2/htdocs httpd:2.4

And check the permissions of the index file:

.. code-block:: bash

  docker exec -it httpd ls -l /usr/local/apache2/htdocs/

You will see this:

.. code-block:: text

  -rw-r--r-- 1 504 staff 45 Jun 11  2007 index.html

You can then edit the file and click on the floppy icon on the right side or just
press CTRL+S (Command+S on macOS) to save the modification.

.. image:: https://onedrive.live.com/embed?resid=9d670019d6697cb6%2133439&authkey=%21AH9h0I_2XVC71eU&width=660
  :width: 660
  :height: 254

Then run the following command from a terminal:

.. code-block:: bash

  docker exec -it httpd ls -l /usr/local/apache2/htdocs/

And you will see that the owner of the file was changed to root.

.. code-block:: text

  total 4
  -rw-r--r-- 1 root root 69 Jan  7 12:21 index.html

One day it might work better, but I generally don't recommend
editing files in containers from the Graphical interface.

Edit only source code that you mount into the container during development
or `Use Compose watch`_ to update the files when you edit them,
but let the data be handled only by the processes in the containers.

Some applications are not optimized for running in containers and there are
different folders and files at the same place where the code is,
so it is hard to work with volumes and mounts while you let the process
in the container change a config file, which you also want to edit occasionally.
In that case you ned to learn how permissions are handled on Linux
using the :code:`chmod` and :code:`chown` commands so you both
have permission to access the files.

Container based dev environments
--------------------------------

Docker Desktop Dev environment
++++++++++++++++++++++++++++++

One of the features of Docker Desktop is that you can run a development
environment in a container. In this tutorial we will not discuss it in
details, but it is good to know that it exists, and you can
basically work inside a container into which you can mount volumes.

More information in the `documentation of the Dev environment <https://docs.docker.com/desktop/dev-environments/>`_

Visual Studio Code remote development
+++++++++++++++++++++++++++++++++++++

The dev environment of Docker Desktop can be opened from Visual Studio Code
as it supports opening projects in containers similarly to how it supports
remote development through SSH connection or in Windows Subsystem for Linux.
You can use it without Docker Desktop to simply open a shell in a container
or even open a project in a container.

More information is in the `documentation of VSCode about containers <https://code.visualstudio.com/docs/containers/overview>`_.

Visual Studio Code dev containers
+++++++++++++++++++++++++++++++++

Microsoft also created container images for creating a dev container,
which is similar to what Docker Desktop supports, but the process
of creating a dev container is different.

More information in the `documentation of VSCode about dev containers <https://code.visualstudio.com/docs/devcontainers/containers>`_.

Conclusion
==========

There are multiple ways to browse the content of the Docker volumes,
but it is not recommended to edit the files on the volumes.
If you know enough about how containers work and what are the folders
and files that you can edit without harming your system,
you probably know enough not to edit the files that way in the first place.

For debugging reasons or to learn about Docker by changing things
in the environment, you can still edit the files at your own risk.

Everything I described in this tutorial is true even if the user is not
an interactive user, but an external user from the container's point of view,
trying to manage files directly in the Docker data root.

So with that in mind if you ever think of doing something like that,
stop for a moment, grab a paper and write the following sentence
20 times to the paper:

"I do not touch the Docker data root directly."

If you enjoyed this tutorial, I also recommend reading about
`Volume-only Compose projects`_.