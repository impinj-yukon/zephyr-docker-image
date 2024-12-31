# Local Zephyr Docker Image

This repository contains the same Dockerfiles as listed below in the forked readme section.

This has been modified to show how to connect a USB dongle for programming targets from docker container.

This has been modified to support a command line argument when building the images to set the username that is created.
This allows the user to connect connect the container to the ssh-agent running on the host (the usernames are required to match).
This way west or git can be used to pull down repos that require ssh keys.

Note that these images have been modified to build locally (originally they pulled from the pre built images).  So
now each image needs to be built locally in order

# Building the Images

```
docker build -f Dockerfile.base \
   --build-arg UID=$(id -u) \
   --build-arg GID=$(id -g) \
   --build-arg USERNAME=$(id -u -n) \
    -t ci-base:latest .
```
```
docker build -f Dockerfile.ci \
    --build-arg UID=$(id -u) \
    --build-arg GID=$(id -g) \
    --build-arg USERNAME=$(id -u -n) \
    -t ci:latest .
```

```
 docker build -f Dockerfile.devel \
     --build-arg UID=$(id -u) \
     --build-arg GID=$(id -g) \
     --build-arg USERNAME=$(id -u -n) \
     -t devel:latest .
```

# Running the devel image with SSH-Agent

Then to run the docker image interactively with the following command that will mount the /workdir volume and connect
the SSH_AUTH_SOCK to the ssh-agent running on the host.

```
docker run -ti \
    -v $HOME/west-workspace:/workdir \
    --mount type=bind,src=$SSH_AUTH_SOCK,target=/run/host-services/ssh-auth.sock \
    -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" \
    devel:latest
```
# Running the devel image with USB Programming dongle.

This command will connect the USB device to the container  (And the entrypoint.sh needs to be modified if the bus/dev values are different).
Details are here https://impinj.atlassian.net/wiki/spaces/INDY/pages/911704083/Building+and+Flashing+Zephyr+in+Docker

```
docker run -ti \
    -v $HOME/west-workspace:/workdir \
    --device=/dev/bus/usb/001/003 \
    devel:latest
```



# Below is the Documentation from the repo this was forked from

# Zephyr Docker Images

This repository contains the Dockerfiles for the following images:

- **Base Image (_ci-base_):** contains only the minimal set of software needed for basic development without the toolchains.
- **CI Image (_ci_):** contains toolchains, the zephyr sdk and additional packages needed for ci operations.
- **Developer Image (_zephyr-build_):** includes additional tools that can be useful for Zephyr
  development.

## Developer Docker Image

### Overview

The Developer docker image includes all tools included in the CI image as well as the additional
tools that can be useful for Zephyr development, such as the VNC server for testing display sample
applications.

The Base docker images should be used to build custom docker images with 3rd party toolchains and tooling.

These images include the [Zephyr SDK](https://github.com/zephyrproject-rtos/sdk-ng), which supports
building most Zephyr targets.

### Installation

#### Using Pre-built Developer Docker Image

The pre-built developer docker image is available on both GitHub Container Registry (`ghcr.io`) and
DockerHub (`docker.io`).

For Zephyr 3.7 LTS, use the `v0.26-branch` or the latest `v0.26.x` release Docker image.

##### GitHub Container Registry (`ghcr.io`)

###### Current Zephyr versions

```
docker run -ti -v $HOME/Work/zephyrproject:/workdir \
           ghcr.io/zephyrproject-rtos/zephyr-build:main
```

###### Zephyr 3.7 LTS

```
docker run -ti -v $HOME/Work/zephyrproject:/workdir \
           ghcr.io/zephyrproject-rtos/zephyr-build:v0.26-branch
```

##### DockerHub (`docker.io`)

###### Current Zephyr versions

```
docker run -ti -v $HOME/Work/zephyrproject:/workdir \
           docker.io/zephyrprojectrtos/zephyr-build:main
```

###### Zephyr 3.7 LTS

```
docker run -ti -v $HOME/Work/zephyrproject:/workdir \
           docker.io/zephyrprojectrtos/zephyr-build:v0.26-branch
```

#### Building Developer Docker Image

The developer docker image can be built using the following command:

```
docker build -f Dockerfile.devel --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t zephyr-build:v<tag> .
```

It can be used for building Zephyr samples and tests by mounting the Zephyr workspace into it:

```
docker run -ti -v <path to zephyr workspace>:/workdir zephyr-build:v<tag>
```

### Usage

#### Building a sample application

Follow the steps below to build and run a sample application:

```
west build -b qemu_x86 samples/hello_world
west build -t run
```

#### Building display sample applications

It is possible to build and run the _native POSIX_ sample applications that produce display outputs
by connecting to the Docker instance using a VNC client.

In order to allow the VNC client to connect to the Docker instance, the port 5900 needs to be
forwarded to the host:

```
docker run -ti -p 5900:5900 -v <path to zephyr workspace>:/workdir zephyr-build:v<tag>
```

Follow the steps below to build a display sample application for the _native POSIX_ board:

```
west build -b native_posix samples/subsys/display/cfb
west build -t run
```

The application display output can be observed by connecting a VNC client to _localhost_ at the
port _5900_. The default VNC password is _zephyr_.

On a Ubuntu host, this can be done by running the following command:

```
vncviewer localhost:5900
```
