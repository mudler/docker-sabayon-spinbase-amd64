# XXX: need to check other stage3 implementations
# use the tianon gentoo stage3
#FROM tianon/gentoo-stage3
#python 3 :(

# https://github.com/jgkim/gentoo-docker
#FROM jgkim/gentoo-stage3

# Layman already installed, w00t!
FROM plabedan/gentoo
# python 2.7

# Setting locales
RUN echo "en_US.UTF-8 UTF-8 " >> /etc/locale.gen
RUN locale-gen
RUN eselect locale set en_US.utf8
RUN env-update && source /etc/profile
ENV LC_ALL=en_US.UTF-8

# Make sure portage is synced and adding sabayon overlay
RUN emerge --sync
RUN layman -a sabayon

# XXX: hackz need to be re-installed, fails in equo rescue generate phase
RUN emerge -C =dev-python/python-exec-0.3.1

# Adding required use flags
ADD ./conf/00-sabayon.package.use /etc/portage/package.use/00-sabayon.package.use

# Adding required keyword changes
ADD ./conf/00-sabayon.package.keywords /etc/portage/package.keywords/00-sabayon.package.keywords

# emerging equo and expect
RUN emerge -vt equo --autounmask-write
RUN emerge expect
RUN mkdir /usr/local/portage

# Generating empty equo db
ADD ./script/generate-equo-db.sh /
ADD ./ext/equo.sql /
RUN chmod +x /generate-equo-db.sh
RUN ./generate-equo-db.sh && rm -rf /equo.sql /generate-equo-db.sh

# Choosing only python2.7 for now, cleaning others
RUN eselect python set python2.7

# XXX: hackz ca-certificates need to be re-installed, fails in equo rescue generate phase
RUN emerge -C python:3.2 python:3.3 app-misc/ca-certificates

RUN rm -rf /etc/make.profile

# Generate equo db, unfortunately we have to use expect
ADD ./script/equo-rescue-generate.exp /
RUN chmod +x /equo-rescue-generate.exp
RUN ./equo-rescue-generate.exp
RUN rm -rf /equo-rescue-generate.exp

# Updating repository db
RUN mv /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org.example /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org
RUN equo up

# Sorting mirrors
RUN equo repo mirrorsort sabayonlinux.org

# Removing portage and keeping profiles and metadata
RUN cd /usr/portage/;ls | grep -v 'profiles' | grep -v 'metadata' | xargs rm -rf

# Accepting licenses needed to continue automatic install/upgrade
ADD ./conf/spinbase-licenses /etc/entropy/packages/license.accept

# Specifying a gentoo profile
RUN eselect profile set default/linux/amd64/13.0/desktop

# Portage configurations
ADD ./script/sabayon-build.sh /sabayon-build.sh
RUN chmod +x /sabayon-build.sh
RUN ./sabayon-build.sh
RUN rm -rf /sabayon-build.sh

RUN equo u

ENV PACKAGES_TO_REMOVE="sys-devel/llvm dev-libs/ppl app-admin/sudo x11-libs/gtk+:3 x11-libs/gtk+:2 mariadb sys-fs/ntfs3g app-accessibility/at-spi2-core app-accessibility/at-spi2-atk sys-devel/base-gcc:4.7 sys-devel/gcc:4.7 net-print/cups"
ENV PACKAGES_TO_ADD="app-text/pastebunz dev-lang/python-exec-0.3.1-r1 sys-boot/grub:2"

# Handling install/removal of packages specified in env (and also the basic needed)
# XXX: sabayon-artwork-core and linux-sabayon should be moved in molecules file
RUN equo i app-misc/ca-certificates linux-sabayon sabayon-artwork-core sabayon-version sabayon-artwork-grub $PACKAGES_TO_ADD
RUN equo rm --force-system $PACKAGES_TO_REMOVE

# Cleaning accepted licenses
RUN rm -rf /etc/entropy/packages/license.accept
# Merging defaults configurations
RUN echo -5 | equo conf update
# Writing package list file
RUN equo q list installed -qv > /etc/sabayon-pkglist 
# Cleaning equo package cache
RUN equo cleanup
