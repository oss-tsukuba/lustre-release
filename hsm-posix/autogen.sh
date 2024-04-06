#!/bin/sh
set -e

aclocal
#autoheader
autoconf
touch AUTHORS ChangeLog README NEWS
automake -a -c
