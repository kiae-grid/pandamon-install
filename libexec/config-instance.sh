#!/bin/sh
#
# Configures PanDA monitor instance.

GROUP=apache
MODE=0640

usage () {
	cat << EOF
Usage: $0 -u username -s software-list-file -t pandamon-template-file
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
EXPERIMENT=atlas
while getopts "e:hs:t:u:" opt; do
	case "X$opt" in
	Xh)
		usage
		exit 0
		;;
	Xe)
		EXPERIMENT="$OPTARG"
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
BASEDIR="$HOME"/src
PYTHON_PATH=$("$MYDIR"/python-path.subr "$BASEDIR" "$SOFTWARE")
[ "$?" != 0 ] && exit 1
VIRTUALENV_PATH="$HOME"/venv

DEST="${HOME}/settings/$(basename "$TEMPLATE")"
sed -e"s|@@PYTHON_PATH@@|${PYTHON_PATH}|g" \
    -e"s|@@VIRTUALENV_PATH@@|${VIRTUALENV_PATH}|g" \
    "$TEMPLATE" > "$DEST"
chown "$USER":"$USER" "$DEST"


LOGROOT="$HOME"/logs
# Create empty configuration files if they don't exist.
for l in panda-bigmon-core/core/common/settings/local.py \
    panda-bigmon-$EXPERIMENT/$EXPERIMENT/settings/local.py; do
	lconf="$HOME/src/$l"
	tpl="$MYDIR/../templates/$(echo "${l#*/}" | tr / -)"
	if ! [ -e "$tpl" ]; then
		echo "Oops!  No template '$tpl'." >&2
		exit 1
	fi
	if ! [ -e "$lconf" ]; then
		sed -e"s|@@LOGROOT@@|$LOGROOT|g" \
		  "$tpl" > "$lconf"
		chmod "$MODE" "$lconf"
		chown "$USER":"$GROUP" "$lconf"
	fi
done


# Extract static files if our source isn't a symlink
# to some other place (in this case the owner of symlinked
# contents is responsible for extraction).
MAIN_CODE="$HOME/src/panda-bigmon-$EXPERIMENT"
if [ -d "$MAIN_CODE" ]; then
	activate="$VIRTUALENV_PATH"/bin/activate
	su -c "source \"${activate}\" || exit 1; cd \"$MAIN_CODE/$EXPERIMENT\"; PYTHONPATH=\"$PYTHON_PATH\" ./manage.py collectstatic -v0 --noinput || exit 1; deactivate" - "$USER" || exit 1
	chgrp apache "$LOGROOT"/logfile.*
fi


# Put a fancy message reminding what should be done next.
cat << EOF

Two configuration files,
  $HOME/src/panda-bigmon-core/core/common/settings/local.py
and
  $HOME/src/panda-bigmon-$EXPERIMENT/$EXPERIMENT/settings/local.py
were put in place, but their contents should be tuned for your
installation (unless you already did that).

Since these files typically contain sensitive information, their
mode should be $MODE, owner should be trusted and group is to be
set to "$GROUP" or some other one that will enable your WSGI process
to read this file.

Good luck!

EOF
