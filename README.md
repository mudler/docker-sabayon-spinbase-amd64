# Sabayon Spinbase: a Docker Project #

Attention! it's under development, thus consider it an alpha

The purpose of this project is to provide an image of Sabayon spinbase.
It is just a gentoo stage3 + entropy

## First steps on docker

Ensure to have the daemon started and running:

    sudo systemctl start docker

## Building docker-sabayon-spinbase locally

    git clone https://github.com/mudler/docker-sabayon-spinbase-amd64.git docker-sabayon-spinbase
    cd docker-sabayon-spinbase
    sudo docker build -t mudler/docker-sabayon-spinbase .

## From Docker Hub

    sudo docker pull sabayon/spinbase-amd64

## From Docker to Molecules

After pulling the docker image, install [undocker](https://github.com/larsks/undocker/) and then as root:

    docker save sabayon/spinbase-amd64:latest | undocker -i -o spinbase sabayon/spinbase-amd64:latest

You can also squash the image with [docker-squash](https://github.com/jwilder/docker-squash) and then extract your layers
The squash can also been accomplished creating a container from the image, exporting it and then importing it back. Docker will loose the history revision and then you can estract the layer, using as base for charoot
