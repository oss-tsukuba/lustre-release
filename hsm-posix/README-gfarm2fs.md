# Lustre HSM for gfarm2fs

## Setup

- Install and configure Gfarm client and gfarm2fs
- Install and configure Lustre client
- ./build.sh
- Add `user_allow_other` to `/etc/fuse.conf`

## Usage

- Explanatory variables
  - GFS_MOUNTDIR ... mountpoint of gfarm2fs
    - ex.: /mnt/gfarm-lustre-hsm
  - GFARMFS_ROOT ... directory on Gfarm for HSM
    - ex.: /LustreHSM
  - MNT_LUSTRE ... mountpoint of Lustre
    - ex.: /mnt/lustre
  - HSM_ARCHIVE ... archive number
    - ex.: 1
  - HSM_OPTIONS ... lhsmtool_posix options
    - ex.: "--no-attr --no-xattr"
    - --no-attr ... required when gfarmroot is not used, or when both users/groups do not match.
    - --no-xattr ... required when xattr on Gfarm is not enabled.
  - MDTNAME ... MDT name
    - ex.: mdt.testfs-MDT0000
  - GFS_USERNAME .. global user in Gfarm
    - ex.: gfarmsys
  - GFARMFS_USERNAME .. local user
    - ex.: gfarmsys
- Operate as GFARM_USER account for Lustre HSM
- Enable sudo for the local user
  - Example for /etc/sudoers.d/gfarm-lustre-hsm:
    - gfarmsys   ALL=(ALL:ALL)  NOPASSWD: ALL
- At MDT host
  - `sudo lctl set_param ${MDTNAME}.hsm_control=enabled`
  - `sudo lctl get_param ${MDTNAME}.hsm_control`
- `sudo mkdir -p $GFS_MOUNTDIR`
- `sudo chmod 700 $GFS_MOUNTDIR`
- `sudo chown $GFARM_USER $GFS_MOUNTDIR`
- `gfsudo gfmkdir -p $GFARMFS_ROOT`
- `sudo sh ./mount-gfarm2fs-and-lhsmtool_posix.sh "$GFS_MOUNTDIR" "$GFARMFS_ROOT" "$GFS_USERNAME" "$GFARMFS_USERNAME" "$MNT_LUSTRE" "$HSM_ARCHIVE" "$HSM_OPTIONS"`
  - ctrl-c to stop
- Example of operations (At another terminal)
  - cd $MNT_LUSTRE
  - sudo mkdir tmp
  - sudo chmod 1777 tmp
  - (file creation, Lustre operations, etc. ...)
  - sudo lfs hsm_archive FILENAME
  - sudo lfs hsm_state FILENAME
    - "exists archived"
  - find ${GFS_MOUNTDIR}/shadow/
  - sudo lfs hsm_release FILENAME
  - sudo lfs hsm_state FILENAME
    - "released exists archived"
  - sudo lfs hsm_restore FILENAME
  - sudo lfs hsm_state FILENAME
    - "exists archived"
  - sudo lfs hsm_remove FILENAME
  - sudo lfs hsm_state FILENAME
    - "file: (0x00000000),"

## Systemd (Example)

- Create `/etc/systemd/system/gfarm-lustre-hsm.service`

```
[Unit]
Description=Lustre HSM for gfarm2fs

[Service]
User=root
StandardOutput=journal
StandardError=journal
Restart=on-failure
KillMode=control-group
KillSignal=SIGTERM
TimeoutStopSec=10
EnvironmentFile=/etc/sysconfig/gfarm-lustre-hsm
ExecStart=/bin/sh -c '/bin/sh -x "$MOUNT_GFARM2FS_HSMTOOL" "$GFS_MOUNTDIR" "$GFARMFS_ROOT" "$GFS_USERNAME" "$GFARMFS_USERNAME" "$MNT_LUSTRE" "$HSM_ARCHIVE" "$HSM
_OPTIONS"'

[Install]
WantedBy=multi-user.target
```

- Create `/etc/sysconfig/gfarm-lustre-hsm`
  - Example:

```
MOUNT_GFARM2FS_HSMTOOL=/home/gfarmsys/lustre-release/hsm-posix/mount-gfarm2fs-and-lhsmtool_posix.sh
GFS_MOUNTDIR=/mnt/gfarm-lustre-hsm
GFARMFS_ROOT=/LustreHSM
GFS_USERNAME=gfarmsys
GFARMFS_USERNAME=gfarmsys
MNT_LUSTRE=/mnt/lustre
HSM_ARCHIVE=1
HSM_OPTIONS=
#HSM_OPTIONS=--no-attr
```

- `sudo systemctl daemon-reload`
- `sudo systemctl enable gfarm-lustre-hsm`
- `sudo systemctl start gfarm-lustre-hsm`
- `sudo journalctl -u gfarm-lustre-hsm` to show the service log

## HSM details

- <https://doc.lustre.org/lustre_manual.xhtml#hsm_introduction>

## Copyright

- See ../COPYING
- Copyright 2024 Osamu Tatebe
- Copyright 2024 Takuya Ishibashi
