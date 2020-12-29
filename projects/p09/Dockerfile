# Based on "Petar Maric outdated image"
# https://github.com/petarmaric/docker.cpu_stress_test

FROM ubuntu:20.04

# Update the Ubuntu package index and install the required Ubuntu packages
RUN apt-get update \
 && apt-get install -y --no-install-recommends stress

# Parameterize this Dockerfile, by storing the app configuration within environment variables 
ENV STRESS_TIMEOUT 120
ENV STRESS_MAX_CPU_CORES 1

CMD stress --cpu $STRESS_MAX_CPU_CORES --timeout $STRESS_TIMEOUT