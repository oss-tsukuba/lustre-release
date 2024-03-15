# Lustre HSM for gfarm2fs

## Setup

- (Install and configure Gfarm client and gfarm2fs)
- (Install and configure Lustre client)
- ./build.sh

## Usage

- Variables
  - GFS_MOUNTDIR ... mountpoint of gfarm2fs
    - ex.: /mnt/gfarm-lustre-hsm
  - GFARMFS_ROOT ... directory on Gfarm for HSM
    - ex.: /LustreHSM
  - MNT_LUSTRE ... mountpoint of Lustre
    - ex.: /mnt/lustre
  - ARCHIVE ... archive number
    - ex.: 1
- Operations by Gfarm user account to use Lustre HSM
- Enable sudo
- `mkdir -p $GFS_MOUNTDIR`
- `gfmkdir -p $GFARMFS_ROOT`
- `sh ./mount-gfarm2fs-and-lhsmtool_posix.sh "$GFS_MOUNTDIR" "$GFARMFS_ROOT" "$MNT_LUSTRE" $ARCHIVE`
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
    - "exists archived"
  - sudo lfs hsm_remove FILENAME
    - "file: (0x00000000),"

## HSM details

- <https://doc.lustre.org/lustre_manual.xhtml#hsm_introduction>

## Copyright

- Copyright 2024 Osamu Tatebe
- Copyright 2024 Takuya Ishibashi
