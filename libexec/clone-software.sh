#!/bin/sh
#
# Executes checkout commands for all provided repositories.
#
# Configuration file is line-oriented with each non-comment
# line carries first word as the repository name and the rest is
# just a shell command (or multiple shell commands) that will be
# executed literally.
#
# We expect that for each repository directory with the same
# name will be created in the $CWD.

usage () {
	cat << EOF
Usage: $0 -u username -s software-list
EOF
}

USER=
SOFTWARE=
while getopts "hs:u:" opt; do
	case "X$opt" in
	Xh)
		usage
		exit 0
		;;
	Xs)
		SOFTWARE="$OPTARG"
		;;
	Xu)
		USER="$OPTARG"
		;;
	X*)
		exit 1
		;;
	esac
done
shift $(($OPTIND - 1))

if [ -z "$SOFTWARE" ]; then
        echo "No software list specified." >&2
        exit 1
fi
if [ -z "$USER" ]; then
        echo "No user name specified." >&2
        exit 1
fi

if ! [ -e "$SOFTWARE" ]; then
	echo "No filesystem object named '$SOFTWARE'." >&2
	exit 1
fi
if [ -d "$SOFTWARE" ]; then
	echo "'$SOFTWARE' is a directory." >&2
	exit 1
fi

grep -v '^[[:space:]]*#' "$SOFTWARE" | while read label command; do
	echo "[+] Doing checkout for ${label}..."
	eval $command || exit 1
	if [ -d "$label" ]; then
		chown -R "$USER":"$USER" "$label" || exit 1
	fi
done
[ "$?" == 0 ] && echo "[+] Seems like everything is done.  \o/" || exit 1
