#!/bin/sh

# Generate VLAN config

# Usage example: ./gen-vlan.sh 1001 default 4 y voice '100 101' sw1

. ./library.sh

set -e
set -u

VLAN_ID="$1"
VLAN_NAME="$2"
VLAN_QOS="$3"
HELPERS="$4"
OPTIONS="$5"
OBSOLETES="$6"
DEVICE="$7"
DEVICE_ID=`host $DEVICE|awk '{print $NF}'|cut -d. -f3-4`
#FILE=tmp/$POLICY.$DEVICE

HELPER_IPS="10.0.1.1 10.0.1.2 10.0.1.3"

cat <<EOF
   static-vlan $VLAN_ID
   vlan $VLAN_ID
      name $VLAN_NAME
EOF

case "$OPTIONS" in
	*NOIGMP*|*voice*)
		echo "      no ip igmp"
		;;
	*)
		echo "      ip igmp"
		if is_querier $DEVICE; then
			echo "      ip igmp querier"
		else
			echo "      no ip igmp querier"
		fi
		;;
esac

case "$OPTIONS" in
	*LEAVEIP*)
		;;
	*NOIP*)
		echo "      no ip address"
		;;
	*DHCP*)
		echo "      ip address dhcp"
		;;
	*)
		echo "      ip address 10.$VLAN_ID.$DEVICE_ID/16"
		if [ -n "$HELPERS" ]; then
			for i in $HELPER_IPS; do
				echo "      ip helper-address $i"
			done
		fi
		if [ -n "$OPTIONS" ]; then
			echo "$OPTIONS" | sed -r -e 's/^/      /g' -e 's/;+ */\n      /g'
		fi
		;;
esac

if [ -n "$VLAN_QOS" ]; then
	echo "      qos priority $VLAN_QOS"
fi

get_vlan_ports $VLAN_ID $DEVICE | sed -e 's/^/      /'

echo "   exit"

for o in $OBSOLETES; do
	echo "   no vlan $o"
done

