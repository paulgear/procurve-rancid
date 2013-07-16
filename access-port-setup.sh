#!/bin/sh

# Set access port settings for each named device

. ./library.sh

set -e
set -u

if [ "$#" -le 0 ]; then
	set -- `get_routers`
fi

for router; do
	ports=`get_access_ports $router`
	voip=`get_voip_compat_ports $router`
	(
	echo "loop trap loop"
	echo "spanning-tree $ports bpdu-protection"
	echo "loop $ports"
	echo "interface $ports unknown-vlans disable"
	if has_interface_limit $router; then
		echo "interface $ports broadcast-limit 10"
	fi
	if [ -n "$voip" ]; then
		echo "no spanning-tree $voip bpdu-protection"
		echo "spanning-tree $voip bpdu-filter"
		echo "loop $voip"
		echo "interface $voip unknown-vlans disable"
	fi
	) > tmp/access-ports.$router
	./apply-file.sh access-ports $router	
done
