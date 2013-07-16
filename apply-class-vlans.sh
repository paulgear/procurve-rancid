#!/bin/sh

# Usage: apply-class-vlans.sh class 1 2 ...
# Apply the listed VLANs to the given switch classes

DEBUG=""
if [ "$#" -gt 0 ]; then
	if [ "$1" = "--debug" ]; then
		DEBUG=1
		shift
	fi
else
	echo "Usage: $0 class/switch vlan ..." >&1
	exit 1
fi

CLASS="$1"
shift
VLANS="$*"

. ./library.sh

if [ "$PROG" = "apply-switch-vlans.sh" ]; then
	LIST=`get_routers $CLASS`
else
	LIST=`get_routers_for_class $CLASS`
fi

for DEVICE in $LIST; do
	echo "**** $DEVICE"
	ID=`host_id $DEVICE`
	FILE=tmp/vlans-$CLASS-$DEVICE
	./gen-vlans.sh $DEVICE $VLANS > $FILE
	if [ -n "$DEBUG" ]; then
		cat $FILE
	else
		run_policy "`policy_filter < $FILE`" $DEVICE
	fi
done

