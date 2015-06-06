# Sabayon Spinbase: a Docker Project #

Attention! it's under development, thus consider it an alpha

The purpose of this project is to provide an image of Sabayon spinbase.
It is just a gentoo stage3 + entropy

## First steps on docker

Ensure to have the daemon started and running:

    sudo systemctl start docker

## Building sabayon-spinbase locally

    git clone https://github.com/mudler/docker-sabayon-spinbase-amd64.git docker-sabayon-spinbase
    cd docker-sabayon-spinbase
    sudo docker build -t mudler/docker-sabayon-spinbase .

## Pulling sabayon-spinbase from Docker Hub

    sudo docker pull sabayon/spinbase-amd64

## Converting the image from Docker to use it with [Molecules](https://github.com/Sabayon/molecules)

### Only with undocker, without squashing the layers

After pulling the docker image, install [undocker](https://github.com/larsks/undocker/) and then as root:

    docker save sabayon/spinbase-amd64:latest | undocker -i -o spinbase sabayon/spinbase-amd64:latest

### Using [docker-squash](https://github.com/jwilder/docker-squash)
You can also squash the image with [docker-squash](https://github.com/jwilder/docker-squash) and then extract your layers.

    sudo docker save sabayon-spinbase:latest | sudo TMPDIR=/dev/shm docker-squash -t sabayon-spinbase:squashed > /your/prefered/path/Spinbase.tar

You can replace /dev/shm with your prefered tmpdir

### With undocker, but squashing the layers

The squash can also been accomplished creating a container from the image, exporting it and then importing it back. 

    sudo docker run -t -i sabayon-spinbase:latest /bin/bash
    $ exit # You should drop in a shell, exit, you should see a container id, otherwise find it :
    sudo docker ps -l
    sudo docker export <CONTAINER ID> | docker import - sabayon-spinbase:squashed
    docker save sabayon/spinbase:squashed | undocker -i -o spinbase sabayon/spinbase:squashed

Docker will loose the history revision and then you can estract the layer, using as base for chroot.

You now have the tree on the *spinbase/* directory
