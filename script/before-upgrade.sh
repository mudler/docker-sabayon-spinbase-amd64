#!/bin/bash
# Updating repository db
mv /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org.example /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org
equo up

# Sorting mirrors
equo repo mirrorsort sabayonlinux.org

# Removing portage and keeping profiles and metadata
cd /usr/portage/;ls | grep -v 'profiles' | grep -v 'metadata' | xargs rm -rf
