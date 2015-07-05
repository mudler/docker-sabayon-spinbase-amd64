FROM sabayon/base-amd64

# Accepting licenses needed to continue automatic install/upgrade
ADD ./conf/spinbase-licenses /etc/entropy/packages/license.accept

# Upgrading packages and perform post-upgrade tasks (mirror sorting, updating repository db)
ADD ./script/post-upgrade.sh /post-upgrade.sh
RUN equo u &&\
	echo -5 | equo conf update && \
	/bin/bash /post-upgrade.sh  && \ 
	rm -rf /post-upgrade.sh
