#!/bin/sh
#
# Installs virtualenv for a given PanDA instance.

usage () {
	cat << EOF
Usage: $0 -u username -r pip-requirements-file
EOF
}

REQUIREMENTS=
USER=
while getopts "hr:u:" opt; do
	case "X$opt" in
	Xr)
		REQUIREMENTS="$OPTARG"
		;;
	Xu)
		USER="$OPTARG"
		;;
	Xh)
		usage
		exit 0
		;;
	X*)
		exit 1
		;;
	esac
done
shift $(($OPTIND - 1))

if [ -z "$USER" ]; then
	echo "No user specified." >&2
	exit 1
fi
if [ -z "$REQUIREMENTS" ]; then
	echo "No requirements file name specified." >&2
	exit 1
fi
if [ "$REQUIREMENTS" == "${REQUIREMENTS#/}" ]; then
	REQUIREMENTS="$(pwd)/$REQUIREMENTS"
fi

user="$USER"
user_home=$(getent passwd "$user" | cut -d : -f 6)
if [ -z "$user_home" ]; then
	echo "Unable to determine home directory for user '$USER'." >&2
	exit 1
fi
env="${user_home}/venv"
activate="$env"/bin/activate
if ! [ -f "$activate" -a -x "$activate" ]; then
	mkdir -p "$env"
	virtualenv "$env"
	chown -R "$user":"$user" "$env"
fi
TMPFILE=
trap 'rm -f "$TMPFILE"' 0 1 2 3 15
TMPFILE=$(mktemp "${user_home}/.venv-list-XXXXXX")
[ -z "$TMPFILE" ] && exit 1
cat "$REQUIREMENTS" >> "$TMPFILE"
chown "$user":"$user" "$TMPFILE"
su -c "source \"${activate}\" || exit 1; pip install -r \"${TMPFILE}\" || exit 1; deactivate" - "$user" || exit 1
