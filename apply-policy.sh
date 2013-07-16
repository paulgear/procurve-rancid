#!/bin/sh

set -e
set -u

. ./library.sh

POLICY="$1"
shift

if [ "$#" -le 0 ]; then
	set -- `get_routers`
fi

for DEVICE; do
	check_pingable $DEVICE || continue
	ID=`host $DEVICE|awk '{print $NF}'|cut -d. -f4`
	FILE=tmp/`basename $POLICY`.$DEVICE
	policy_filter < $POLICY > $FILE
	hlogin -c"configure;`cat $FILE`;exit;write memory" $DEVICE
done

