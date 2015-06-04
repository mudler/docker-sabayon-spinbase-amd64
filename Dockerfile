# use the tianon gentoo stage3
#FROM tianon/gentoo-stage3
#python 3 :(

# https://github.com/jgkim/gentoo-docker
#FROM jgkim/gentoo-stage3

# Layman already installed, w00t!
FROM plabedan/gentoo
# python 2.7

# make sure the package repository is up to date
RUN emerge --sync
RUN layman -a sabayon

RUN emerge -C =dev-python/python-exec-0.3.1
RUN echo "en_US.UTF-8 UTF-8 " >> /etc/locale.gen
RUN locale-gen
RUN eselect locale set en_US.utf8
RUN env-update

# Adding required use flags

ADD ./conf/00-sabayon.package.use /etc/portage/package.use/00-sabayon.package.use

# Adding required keyword changes

ADD ./conf/00-sabayon.package.keywords /etc/portage/package.keywords/00-sabayon.package.keywords

RUN emerge -vt equo --autounmask-write
RUN emerge expect


ADD ./script/generate-equo-db.sh /
ADD ./ext/equo.sql /
RUN chmod +x /generate-equo-db.sh
RUN ./generate-equo-db.sh && rm -rfv /equo.sql /generate-equo-db.sh
RUN eselect python set python2.7
RUN emerge -C python:3.2 python:3.3 app-misc/ca-certificates

RUN eselect locale set en_US.utf8
RUN . /etc/profile

# Generate equo db, unfortunately we have to use expect
ADD ./script/equo-rescue-generate.exp /
RUN chmod +x /equo-rescue-generate.exp
RUN ./equo-rescue-generate.exp
RUN rm -rfv /equo-rescue-generate.exp
RUN cp -rfv /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org.example /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org
RUN equo up

RUN wget https://raw.githubusercontent.com/Sabayon/build/master/conf/intel/portage/package.license -O /etc/portage/package.license

# Now we can clean from spinbase the stuff easily
RUN equo rm --configfiles --deep dev-tcltk/expect dev-lang/tcl

#RUN equo repo mirrorsort sabayonlinux.org

RUN rm -rf /usr/portage/*
#RUN equo i app-misc/ca-certificates

