#!/bin/sh

set -e
set -u

. ./library.sh

FILE="$1"
shift

if [ "$#" -le 0 ]; then
	set -- `get_routers`
fi

for DEVICE; do
	check_pingable $DEVICE || continue
	ID=`host $DEVICE|awk '{print $NF}'|cut -d. -f4`
	hlogin -c"configure;$(policy_filter < tmp/$(basename $FILE).$DEVICE);exit;write memory" $DEVICE
done

