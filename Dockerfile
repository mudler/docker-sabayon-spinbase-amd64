FROM sabayon/base-amd64:latest

MAINTAINER mudler <mudler@sabayonlinux.org>

# Accepting licenses needed to continue automatic install/upgrade
ADD ./conf/spinbase-licenses /etc/entropy/packages/license.accept

# Adding nopurge config
ADD ./conf/locale.nopurge /etc/locale.nopurge

# Upgrading packages and perform post-upgrade tasks (mirror sorting, updating repository db)
ADD ./script/post-upgrade.sh /post-upgrade.sh

RUN rsync -av "rsync://rsync.at.gentoo.org/gentoo-portage/licenses/" "/usr/portage/licenses/" && ls /usr/portage/licenses -1 | xargs -0 > /etc/entropy/packages/license.accept && \
	equo u && \
	echo -5 | equo conf update 
RUN /bin/bash /post-upgrade.sh  && \ 
	rm -rf /post-upgrade.sh

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["bash"]
