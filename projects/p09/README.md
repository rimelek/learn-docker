# Project: p09

We test the CPU limit in this example using an image based on [petermaric/docker.cpu-stress-test](https://hub.docker.com/r/petarmaric/docker.cpu-stress-test). Since that image is outdated, we create a new image similar to Peter Maric's work.

```bash
docker build -t localhost/stress .
```

Execute the following command to test a whole CPU core:

```bash
docker run -it --rm \
  -e STRESS_MAX_CPU_CORES=1 \
  -e STRESS_SYSTEM_FOR=30 \
  --cpus=1 \
  localhost/stress
```

Run "top" in an other terminal to see that the "stress" process uses 100% of one CPU. 

Press Ctrl-C and execute the following command to test two CPU core and allow the container to use only 1 and a half CPU.

```bash
docker run -it --rm \
  -e STRESS_MAX_CPU_CORES=2 \
  -e STRESS_TIMEOUT=30 \
  --cpus=1.5 \
  localhost/stress
```

Use "top" again to see that the "stress" process uses 75% of two CPU.

You can test on one CPU core again and allow the container to use 50% of 
a specific CPU core by setting the core index.

```bash
docker run -it --rm \
  -e MAX_CPU_CORES=1 \
  -e STRESS_SYSTEM_FOR=60 \
  --cpus=0.5 \
  --cpuset-cpus=0 \
  localhost/stress
```

You can use top again, but do not forget to add the index column to the list:

* run "top"
* press "f"
* Select column "P" by navigating with the arrow keys
* Press "SPACE" to select "P" 
* Press "ESC"

Now you can see the indexes in the column "P".

Press "1" to list all the CPU-s at the top of the terminal so you can see the usage of all the CPU-s.

Clean the project:

```bash
docker-compose down
```

[Back to the main page](../../README.md)