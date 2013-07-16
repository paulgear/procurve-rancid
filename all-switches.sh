#!/bin/sh

# Usage: all-switches.sh "command" switch ...
# run a command on all switches (or all specified switches)

#set -e
set -u

. ./library.sh

if [ "$1" = "--class" ]; then
	shift
	CLASS="$1"
	shift
else
	CLASS=""
fi

if [ "$#" -lt 1 ]; then
	echo "Usage:	$PROG --class classname 'command'
	$PROG 'command' [pattern]" >&2
	exit 1
fi
CMD="$1"
shift

if [ -n "$CLASS" ]; then
	set -- `get_routers_for_class "$CLASS"`
else
	if [ "$#" -le 0 ]; then
		set -- `get_routers`
	fi
fi

set +e
for DEVICE; do
	run_command "$CMD" $DEVICE
done
set -e

