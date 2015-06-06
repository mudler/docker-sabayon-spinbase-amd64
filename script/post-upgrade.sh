#!/bin/bash

PACKAGES_TO_REMOVE=(
    "sys-devel/llvm"
    "dev-libs/ppl"
    "app-admin/sudo"
    "x11-libs/gtk+:3"
    "x11-libs/gtk+:2"
    "dev-db/mariadb"
    "sys-fs/ntfs3g"
    "app-accessibility/at-spi2-core"
    "app-accessibility/at-spi2-atk"
    "sys-devel/base-gcc:4.7"
    "sys-devel/gcc:4.7"
    "net-print/cups"
    "dev-util/gtk-update-icon-cache"
    "dev-qt/qtscript"
    "dev-qt/qtchooser"
    "dev-qt/qtcore"
    "app-shells/zsh"
    "app-shells/zsh-pol-config"
    "dev-db/mysql-init-scripts"
    "dev-lang/ruby"
    "app-editors/vim"
    "dev-util/gtk-doc-am"
    "media-gfx/graphite2"
    "x11-apps/xset"
    "x11-themes/hicolor-icon-theme"
    "media-libs/tiff"
    "app-eselect/eselect-lcdfilter"
    "app-eselect/eselect-mesa"
    "app-eselect/eselect-opengl"
    "app-eselect/eselect-qtgraphicssystem"
    "x11-libs/pixman"
    "x11-libs/libvdpau"
    "x11-libs/libxshmfence"
    "x11-libs/libXxf86vm"
    "x11-libs/libXinerama"
    "x11-libs/libXdamage"
    "x11-libs/libXcursor"
    "x11-libs/libXfixes"
    "x11-libs/libXv"
    "x11-libs/libXcomposite"
    "x11-libs/libXrandr"
    "media-libs/jbig2dec"
    "dev-libs/libcroco"
    "app-text/qpdf"
    "media-fonts/urw-fonts"
    "app-text/libpaper"
    "dev-python/snakeoil"
    "dev-libs/atk"
    "dev-perl/DBI"
    "perl-core/Digest-MD5"
    "perl-core/MIME-Base64"
    "perl-core/File-Temp"
    "perl-core/ExtUtils-MakeMaker"
    "perl-core/Params-Check"
    "perl-core/Module-CoreList"
    "perl-core/Digest"
    "dev-perl/TermReadKey"
    "dev-perl/Test-Deep"
    "virtual/perl-IO-Zlib"
    "virtual/perl-Package-Constants"
    "virtual/perl-Term-ANSIColor"
    "virtual/perl-Time-HiRes"
    "app-text/asciidoc"
    "app-text/sgml-common"
    "virtual/python-argparse"
    "sys-power/upower"
)

PACKAGES_TO_ADD=(
    "app-text/pastebunz"
    "app-admin/perl-cleaner"
)

# Handling install/removal of packages specified in env

equo i "${PACKAGES_TO_ADD[@]}"
equo rm --deep --configfiles --force-system "${PACKAGES_TO_REMOVE[@]}"

# Cleaning accepted licenses
rm -rf /etc/entropy/packages/license.accept

# Merging defaults configurations
echo -5 | equo conf update

# Writing package list file
equo q list installed -qv > /etc/sabayon-pkglist

# Cleaning equo package cache
equo cleanup

# Cleanup Perl cruft
perl-cleaner --ph-clean

# remove SSH keys
rm -rf /etc/ssh/*_key*

# Needed by systemd, because it doesn't properly set a good
# encoding in ttys. Test it with (on tty1, VT1):
# echo -e "\xE2\x98\xA0"
# TODO: check if the issue persists with systemd 202.
echo FONT=LatArCyrHeb-16 > /etc/vconsole.conf

# remove LDAP keys
rm -f /etc/openldap/ssl/ldap.pem /etc/openldap/ssl/ldap.key \
/etc/openldap/ssl/ldap.csr /etc/openldap/ssl/ldap.crt
