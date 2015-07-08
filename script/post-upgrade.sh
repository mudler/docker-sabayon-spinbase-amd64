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
    "dev-python/py"
    "dev-vcs/git"
    "dev-tcltk/expect"
    "app-admin/python-updater"
    "app-portage/eix"
    "app-portage/gentoolkit"
    "app-portage/gentoopm"
)

FILES_TO_REMOVE=(
   "/.viminfo"
   "/.history"
   "/.zcompdump"
   "/var/log/emerge.log"
   "/var/log/emerge-fetch.log"
)

PACKAGES_TO_ADD=(
    "app-eselect/eselect-bzimage"
    "app-text/pastebunz"
    "app-admin/perl-cleaner"
    "sys-apps/grep"
    "sys-apps/busybox"
    "app-misc/sabayon-live"
    "sys-boot/grub:2"
    "dev-lang/perl"
    "dev-lang/python"
    "x11-themes/sabayon-artwork-core"
    "sys-devel/binutils"
    "app-misc/sabayon-version"
    "x11-themes/sabayon-artwork-grub"
    "app-crypt/gnupg"
    "x11-themes/sabayon-artwork-isolinux"
    "app-crypt/shim-signed"
    "dev-perl/Module-Build"
)

# Handling install/removal of packages specified in env

equo repo mirrorsort sabayonlinux.org
equo up
#equo i $(cat /etc/sabayon-pkglist | xargs echo)
equo rm --deep --configfiles --force-system "${PACKAGES_TO_REMOVE[@]}"
equo i "${PACKAGES_TO_ADD[@]}"

# Setting bzimage
eselect bzimage set 1

# Cleaning accepted licenses
rm -rf /etc/entropy/packages/license.accept

# Upgrading kernel to latest version
kernel_target_pkg="sys-kernel/linux-sabayon"

available_kernel=$(equo match "${kernel_target_pkg}" -q --showslot)
echo
echo "@@ Upgrading kernel to ${available_kernel}"
echo
kernel-switcher switch "${available_kernel}" || exit 1

# now delete stale files in /lib/modules
for slink in $(find /lib/modules/ -type l); do
    if [ ! -e "${slink}" ]; then
        echo "Removing broken symlink: ${slink}"
        rm "${slink}" # ignore failure, best effort
        # check if parent dir is empty, in case, remove
        paren_slink=$(dirname "${slink}")
        paren_children=$(find "${paren_slink}")
        if [ -z "${paren_children}" ]; then
            echo "${paren_slink} is empty, removing"
            rmdir "${paren_slink}" # ignore failure, best effort
        fi
    fi
done

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

# Remove scripts
rm -rf /post-upgrade.sh

# Cleanup
rm -rf "${FILES_TO_REMOVE[@]}"
