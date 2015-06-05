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

