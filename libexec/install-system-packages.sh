#!/bin/sh
#
# Installs system-wide packages that are needed for PanDA monitoring.

yum install -y python-pip python-virtualenv \
  httpd mod_wsgi \
  mysql-devel \
  python-devel gcc \
  libcurl-devel libev-devel
