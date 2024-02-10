# SPDX-License-Identifier: GPL-2.0

AUTOMAKE_OPTIONS = foreign
AM_CFLAGS  = -fPIC -D_GNU_SOURCE -DHAVE_COPY_FILE_RANGE
AM_CPPFLAGS = -I../libcfs/include -I../lnet/utils -I../lustre/utils

bin_PROGRAMS = lhsmtool_posix
lhsmtool_posix_SOURCES = lhsmtool_posix.c pid_file.c

