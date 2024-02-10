# SPDX-License-Identifier: GPL-2.0

AC_PREREQ(2.57)
AC_INIT(lustre-posix-copytool, 0.1)
AC_CONFIG_SRCDIR([.])
AM_INIT_AUTOMAKE

AC_PROG_CC

AC_CHECK_LIB(pthread, pthread_exit)
AC_CHECK_LIB(lnetconfig, yaml_parser_log_error)
AC_CHECK_LIB(lustreapi, llapi_error)

AC_CONFIG_FILES(Makefile)
AC_OUTPUT
