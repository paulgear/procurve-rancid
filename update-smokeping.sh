#!/bin/sh

. ./library.sh

make_smokeping ~/procurve/router.db > /etc/smokeping/config.d/Switches
find_gateways | make_smokeping_bare > /etc/smokeping/config.d/Gateways
