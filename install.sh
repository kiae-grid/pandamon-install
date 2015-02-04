#!/bin/sh
#
# Installs and configures PanDA monitor instance.

# Default action sequence
ALL="
  install-system-packages
  create-users
  install-virtualenv
  clone-software
  config-httpd
  config-instance
"

MYDIR=$(dirname "$0")
if [ -z "$MYDIR" ]; then
	echo "Can't determine my own directory." >&2
	exit 1
fi
[ "$MYDIR" == "${MYDIR#/}" ] && MYDIR="$(pwd)/$MYDIR"
LIBEXEC="$MYDIR"/libexec
TEMPLATES="$MYDIR"/templates

usage () {
	cat << EOF
Usage: $0 -c config-file [action1] [action2] [...]

Default action list: $ALL
EOF
}


# Wrappers for action scripts.
install_system_packages () {
	"$LIBEXEC"/install-system-packages.sh
}

create_users () {
	"$LIBEXEC"/create-users.sh -i "$UID_GID" -u "$USER" -H "$HOMEDIR"
}

install_virtualenv () {
	"$LIBEXEC"/install-virtualenv.sh -u "$USER" -r "$VIRTUALENV_PACKLIST"
}

clone_software () {
	(cd "$HOMEDIR"/src && "$LIBEXEC"/clone-software.sh -u "$USER" -s "$CHECKOUT_CONF")
}

config_httpd () {
	"$LIBEXEC"/config-httpd.sh -u "$USER" -i "$INSTANCE" -s "$CHECKOUT_CONF" -t "$TEMPLATES"/httpd-pandamon.conf -e "$EXPERIMENT"
}

config_instance () {
	"$LIBEXEC"/config-instance.sh -u "$USER" -s "$CHECKOUT_CONF" -t "$TEMPLATES"/settings_bigpandamon_"$EXPERIMENT".py -e "$EXPERIMENT"
}


## Main code starts here

CONFIG=
while getopts "hc:" opt; do
	case "X$opt" in
	Xh)
		usage
		exit 0
		;;
	Xc)
		CONFIG="$OPTARG"
		;;
	X*)
		exit 1
		;;
	esac
done
shift $(($OPTIND - 1))

if [ -z "$CONFIG" ]; then
	echo "No configuration file provided." >&2
	exit 1
fi

. "$CONFIG" || exit 1
for i in VIRTUALENV_PACKLIST INSTANCE USER UID_GID HOMEDIR CHECKOUT_CONF; do
	eval "tmp=\${$i}"
	if [ -z "$tmp" ]; then
		echo "Variable "$i" is not defined." >&2
		echo "Check your configuration file '$CONFIG'." >&2
		exit 1
	fi
done
[ -z "$EXPERIMENT" ] && EXPERIMENT="atlas"


# Run default actions if no actions were specified.
[ -z "$1" ] && set -- $ALL


# Run fixups
if [ "${VIRTUALENV_PACKLIST}" == "${VIRTUALENV_PACKLIST#/}" ]; then
	VIRTUALENV_PACKLIST="${MYDIR}/settings/${VIRTUALENV_PACKLIST}"
fi
if [ "${CHECKOUT_CONF}" == "${CHECKOUT_CONF#/}" ]; then
	CHECKOUT_CONF="${MYDIR}/settings/${CHECKOUT_CONF}"
fi
if [ "${HOMEDIR}" == "${HOMEDIR#/}" ]; then
	echo "Not sure that relative HOMEDIR ($HOMEDIR) will work." >&2
	exit 1
fi


# Fire! ;)
for i in "$@"; do
	action=$(echo "$i" | tr - _)
	echo "=====[ Running ${i}..."
	$action || exit 1
done
