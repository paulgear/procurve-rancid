#!/bin/sh

# Generate VLAN configs for the given device and given VLANs
# If no VLANs are given after the device, generate all VLAN configs

set -e
set -u

DEVICE=$1
shift
TMP=`mktemp`

. ./library.sh

if [ "$#" -gt 0 ]; then
	VLANS="$*"
else
	VLANS=`get_vlans $DEVICE`
fi

for i in $VLANS; do
	grep "^$i," VLANS > $TMP
	OLDIFS="$IFS"
	IFS=","
	read ID NAME QOS OPTIONS OBSOLETES < $TMP
	IFS="$OLDIFS"
	./gen-vlan.sh $ID $NAME $QOS "`is_helper $DEVICE`" "$OPTIONS" "$OBSOLETES" $DEVICE
done

