# alpine-s6-base
Simple Alpine Linux Docker image for linux/amd64, linux/arm/v6 (RaspberryPi 1), linux/arm/v7 (RaspberryPi 2,3&4), linux/arm64 (RaspberryPi 4), linux/ppc64le, linux/s390xx86_64 with s6 supervisor and bash

## Usage
Just pull docker image from docker hub with the command below and image for your platform will be ready for you.
```bash
docker pull raxetul/alpine-s6-base
```

If you want to build images that inherit this image, you may see my other repos starting with the name alpine-s6-*** and find out how I use this base image by checking Dockerfiles.

## Build status
[![Github Actions Build Status](https://github.com/raxetul/alpine-s6-base/workflows/{workflowName}/badge.svg)](https://github.com/raxetul/alpine-s6-base/actions)

