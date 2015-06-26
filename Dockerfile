FROM sabayon/base-amd64

# Accepting licenses needed to continue automatic install/upgrade
ADD ./conf/spinbase-licenses /etc/entropy/packages/license.accept

# Upgrading packages
RUN equo u && echo -5 | equo conf update

# Perform post-upgrade tasks (mirror sorting, updating repository db)
ADD ./script/post-upgrade.sh /post-upgrade.sh
RUN /bin/bash /post-upgrade.sh  && rm -rf /post-upgrade.sh
