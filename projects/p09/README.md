# Project: p09

We test the CPU limit in this example using [petermaric/docker.cpu-stress-test](https://hub.docker.com/r/petarmaric/docker.cpu-stress-test).

```bash
docker run -ti -e MAX_CPU_CORES=1 -e STRESS_SYSTEM_FOR=30s --cpus=1 petarmaric/docker.cpu-stress-test
```

Run "top" in an other terminal to see that the "stress" process uses 100% of one CPU. 

```bash
docker run -ti -e MAX_CPU_CORES=2 -e STRESS_SYSTEM_FOR=30s --cpus=1.5 petarmaric/docker.cpu-stress-test
```

USe "top" again to see that the "stress" process uses 75% of two CPU.

```bash
docker run -ti -e MAX_CPU_CORES=1 -e STRESS_SYSTEM_FOR=30s --cpus=0.5 --cpuset-cpus=0 petarmaric/docker.cpu-stress-test
```

Running the above command we told the stress test to use 50% of the CPU with the index 0.

You can use top again, but do not forget to add the index column to the list:

* run "top"
* press "f"
* Select column "P" by navigating with the arrow keys
* Press "SPACE" to select "P" 
* Press "ESC"

Now you can see the indexes in the column "P".

Press "1" to list all the CPU-s at the top of the terminal so you can see the usage of all the CPU-s.

[Back to the main page](../../README.md)