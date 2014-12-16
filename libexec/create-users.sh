#!/bin/sh
#
# Creates user and group for PanDA monitoring instance.

HTTPD_USER=apache

usage () {
	cat << EOF
Usage: $0 -u user/group-name -i uid/gid -H home-dir
EOF
}

ID=
NAME=
HOME=
while getopts "hi:u:H:" opt; do
	case "X$opt" in
	Xh)
		usage
		exit 0
		;;
	Xi)
		ID="$OPTARG"
		;;
	Xu)
		NAME="$OPTARG"
		;;
	XH)
		HOME="$OPTARG"
		;;
	X*)
		exit 1
		;;
	esac
done
shift $(($OPTIND - 1))

if [ -z "$ID" ]; then
	echo "No uid/gid specified." >&2
	exit 1
fi
if [ -z "$NAME" ]; then
	echo "No user/group name specified." >&2
	exit 1
fi
if [ -z "$HOME" ]; then
	echo "No home directory specified." >&2
	exit 1
fi

getent passwd "$NAME" && exit 0

groupadd -g "$ID" "$NAME"
useradd -u "$ID" -g "$ID" "$NAME" -d "$HOME"
getent passwd "$NAME"
chgrp "$HTTPD_USER" "$HOME"
chmod g+rx "$HOME"
for d in logs settings src; do
	path="$HOME"/"$d"
	mkdir "$path"
	chown "$ID":"$ID" "$path"
done
path="$HOME"/logs
chgrp "$HTTPD_USER" "$path"
chmod g+rwx "$path"
path="$HOME"/settings/__init__.py
touch "$path"
chown "$ID":"$ID" "$path"
