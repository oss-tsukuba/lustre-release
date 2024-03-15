#!/bin/sh

set -eu

GFS_MOUNTDIR="$1"
GFARMFS_ROOT="$2"
MNT_LUSTRE="$3"
ARCHIVE="$4"

DIR=$(dirname $0)
HSM_ROOT=${GFS_MOUNTDIR}
HSMTOOL=${DIR}/lhsmtool_posix

#DAEMON=--daemon
DAEMON=

# user_allow_other is required
grep "^user_allow_other" /etc/fuse.conf

clean() {
    GFS_MOUNTDIR=$GFS_MOUNTDIR GFARMFS_ROOT=$GFARMFS_ROOT \
                umount.gfarm2fs || true
}

clean
trap clean EXIT

gfmkdir -p $GFARMFS_ROOT
mkdir -p $GFS_MOUNTDIR
chown $USER $GFS_MOUNTDIR

GFS_MOUNTDIR=$GFS_MOUNTDIR GFARMFS_ROOT=$GFARMFS_ROOT \
            FUSE_OPTIONS="-o allow_root" mount.gfarm2fs
sudo $HSMTOOL $DAEMON --hsm-root $HSM_ROOT --archive=${ARCHIVE} $MNT_LUSTRE
