#!/bin/sh

set -eu

GFS_MOUNTDIR="$1"
GFARMFS_ROOT="$2"
GFS_USERNAME="$3"
GFARMFS_USERNAME="$4"
MNT_LUSTRE="$5"
HSM_ARCHIVE="$6"
HSM_OPTIONS="$7"

DIR=$(dirname $0)
HSM_ROOT=${GFS_MOUNTDIR}
HSMTOOL=${DIR}/lhsmtool_posix

# user_allow_other is required
grep -q "^user_allow_other" /etc/fuse.conf

RUN="runuser -u $GFARMFS_USERNAME --"

ignore() {
    return 0
}

clean() {
    GFS_MOUNTDIR=$GFS_MOUNTDIR \
		GFS_USERNAME=$GFS_USERNAME \
		umount.gfarm2fs 2> /dev/null || ignore
}

INT=0
child_pid=0

interrupt() {
    INT=1

    if [ $child_pid -ne 0 ]; then
        kill -TERM "$child_pid" || ignore
        wait "$child_pid"
    fi
}

pkill -KILL -f "^$HSMTOOL " || ignore
clean
trap interrupt SIGINT SIGTERM
trap clean EXIT

if pgrep -af "^$HSMTOOL "; then
    echo >&2 "Error: $HSMTOOL is running"
    exit 1
fi

$RUN gfmkdir -p $GFARMFS_ROOT

mkdir -p $GFS_MOUNTDIR
chmod 700 $GFS_MOUNTDIR
chown $USER $GFS_MOUNTDIR

GFS_MOUNTDIR=$GFS_MOUNTDIR \
	    GFARMFS_ROOT=$GFARMFS_ROOT \
	    GFS_USERNAME=$GFS_USERNAME \
	    GFARMFS_USERNAME=$GFARMFS_USERNAME \
	    FUSE_OPTIONS="-s -o allow_root" \
	    mount.gfarm2fs

set +e
$HSMTOOL $HSM_OPTIONS --hsm-root $HSM_ROOT --archive=${HSM_ARCHIVE} $MNT_LUSTRE &
child_pid=$!
wait "$child_pid"
rv=$?
if [ $INT -eq 1 ]; then
    rv=0
fi
exit $rv
