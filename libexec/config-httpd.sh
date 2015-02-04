#!/bin/sh
#
# Configures Apache

CONF_D=/etc/httpd/conf.d

usage () {
	cat << EOF
Usage: $0 -e experiment -u username -i instance -s software-list-file -t wsgi-template-file
EOF
}

MYDIR="$(dirname "$0")"
if [ -z "$MYDIR" ]; then
	echo "Can't determine my base directory." >&2
	exit 1
fi

USER=
SOFTWARE=
TEMPLATE=
INSTANCE=
EXPERIMENT=atlas
while getopts "e:hi:s:t:u:" opt; do
	case "X$opt" in
	Xh)
		usage
		exit 0
		;;
	Xe)
		EXPERIMENT="$OPTARG"
		;;
	Xi)
		INSTANCE="$OPTARG"
		;;
	Xs)
		SOFTWARE="$OPTARG"
		;;
	Xt)
		TEMPLATE="$OPTARG"
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
if [ -z "$TEMPLATE" ]; then
	echo "No template file specified." >&2
	exit 1
fi
if [ -z "$INSTANCE" ]; then
	echo "No instance name specified." >&2
	exit 1
fi

if ! [ -e "$TEMPLATE" ]; then
	echo "Template file '$TEMPLATE' does not exists." >&2
	exit 1
fi
if [ -d "$TEMPLATE" ]; then
	echo "Template '$TEMPLATE' is a directory." >&2
	exit 1
fi

if ! [ -e "$SOFTWARE" ]; then
	echo "Software list '$SOFTWARE' does not exists." >&2
	exit 1
fi
if [ -d "$SOFTWARE" ]; then
	echo "Software list '$SOFTWARE' is a directory." >&2
	exit 1
fi


HOME=$(getent passwd "$USER" | cut -d : -f 6)
if [ -z "$HOME" ]; then
	echo "Can't get home directory for user '$USER'." >&2
	exit 1
fi
INSTANCE_SOFT_BASEDIR="$HOME"/src
PYTHON_PATH=$("$MYDIR"/python-path.subr "$INSTANCE_SOFT_BASEDIR" "$SOFTWARE")
[ "$?" != 0 ] && exit 1

sed -e"s|@@PYTHON_PATH@@|${HOME}/settings:${PYTHON_PATH}|g" \
    -e"s|@@EXPERIMENT@@|${EXPERIMENT}|g" \
    -e"s|@@INSTANCE@@|${INSTANCE}|g" \
    -e"s|@@INSTANCE_SOFT_BASEDIR@@|${INSTANCE_SOFT_BASEDIR}|g" \
    "$TEMPLATE" > "${CONF_D}/pandamon-${INSTANCE}.conf"
