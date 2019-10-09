# Project: p08

## Description

This example shows the memory testing in a PHP container, where the "truncate"
command generates a file with a defined size and the PHP reads it into the memory.
We use an environment variable to set the memory size.

## Start the test

The container will have 50MB memory limit. (It must be at least 4MB). 
The examples below will test the memory usage from 10MB to 50MB increased by 10MB for each test.

```bash
MEMSIZE=10MB docker-compose run --rm php
MEMSIZE=20MB docker-compose run --rm php
MEMSIZE=30MB docker-compose run --rm php
MEMSIZE=40MB docker-compose run --rm php
MEMSIZE=50MB docker-compose run --rm php
# bash: line 1:  8 Killed   php -r ' ob_start(); readfile("/tmp/50MB"); ob_clean(); echo (memory_get_peak_usage(true)/1024/1024)." MiB\n"; '
```

"Killed" means we exceeded the memory limit. There is no error until 50MB. It is not a 100% exact result but it shows
the error occurs about 50MB.

## Explanation of the parameters

The "docker-compose run" is similar to "docker run", but it runs a service from the compose file.
"--rm" means the same as it meant for "docker run". Deletes the container right after it stopped.

[Back to the main page](../../README.md)