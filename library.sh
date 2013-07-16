# shell library functions

if [ "$0" != "-su" ]; then
	PROG=`basename $0`
fi
PATH=$PATH:
MYDOMAIN=example.com
mkdir -p tmp

# check if a node is pingable
check_pingable()
{
	if ping -A -c 2 -q "$@" >/dev/null; then
		return 0
	else
		echo "***** $@ unreachable"
		return 1
	fi
}

# get ID for host
host_id()
{
	host $1|awk '{print $NF}'|cut -d. -f4
}

# run the given command on the given device
run_command()
{
	check_pingable $2 && hlogin -c"$1" $2
}

# run the given command inside a "configure; ...; exit; write memory" block
run_policy()
{
	run_command "configure;$1;exit;write memory" $2
}

# shell function to get the routers on the command line, or all if none are specified
get_routers()
{
	if [ $# -lt 1 ]; then
		cut -d: -f1 ../router.db
	else
		grep -e "$1" ../router.db|cut -d: -f1
	fi | grep -v '^[ 	]*#'
}

# filter policy files for passing to RANCID's clogin -c
policy_filter()
{
	sed -r \
		-e "/^[ 	]*#/d" \
		-e "s/^[ 	]*//" \
		-e "s/[ 	]*$//g" \
		-e "s/__DEVICE__/$DEVICE/g" \
		-e "s/__DEVICEID__/$ID/g" \
			| tr '\n' ';' | sed -e "s/;$//"
}

# echo 'y' and return true if router is a helper
is_helper()
{
	has_class $1 helper
	ret="$?"
	if [ $ret -eq 0 ]; then
		echo y
	fi
	return $ret
}

# return true if router is an igmp querier
is_querier()
{
	has_class $1 querier
}

# return true if router is in a class
has_class()
{
	get_classes "$1" | grep -q "^$2$"
}

# return all classes for the given router
get_classes()
{
	ROUTER="$1" perl -e '
	while (<>) {
		next if /^\s*#/;
		chomp;
		my @F = split;
		my $sw = shift @F;
		next unless $sw eq $ENV{ROUTER};
		print join("\n", @F) . "\n";
	}
	exit 0;
	' CLASSES
}

# get all routers for the given class
get_routers_for_class()
{
	CLASS="$1" perl -e '
	while (<>) {
		next if /^\s*#/;
		chomp;
		my @F = split;
		my $sw = shift @F;
		print("$sw\n") if grep(/\b$ENV{CLASS}\b/, @F);
	}
	exit 0;
	' CLASSES
}

# get all VLAN ids for a given router
get_vlans()
{
	ROUTER="$1" perl -e '
	while (<>) {
		next if /^\s*#/;
		chomp;
		my @F = split;
		my $vlan = shift @F;
		if (grep(/\bALL\b/, @F)) {
			print("$vlan\n");
			next;
		}
		print("$vlan\n") if grep(/\b$ENV{ROUTER}\b/, @F);
	}
	exit 0;
	' VLAN-switches
}

# get all port assignments for a given device & VLAN
get_vlan_ports()
{
	VLAN="$1"
	ROUTER="$2" perl -e '
	while (<>) {
		next if /^\s*#/;
		chomp;
		if (/^\s*(\S+)\s*(.*)$/) {
			next unless $1 eq $ENV{ROUTER};
			print "$2\n";
		}
	}
	' VLAN-ports/$VLAN
}

get_model()
{
	ROUTER="$1"
	awk '/Chassis type/ {print $3}' ../configs/$ROUTER
}

has_interface_limit()
{
	ROUTER="$1"
	MODEL="`get_model $ROUTER`"
	grep -q "^$MODEL.*NOLIMIT" MODELS && return 1 || return 0
}

get_access_ports()
{
	ROUTER="$1"
	grep -v VOICE ACCESS-PORTS | awk "/^$ROUTER	/ "'{print $2}'
}

get_voip_compat_ports()
{
	ROUTER="$1"
	awk "/^$ROUTER	.*	VOICE/ "'{print $2}' ACCESS-PORTS
}

make_smokeping()
{
	FILE="$1"
	awk -F: '/^[^#]/ {print $1}' "$FILE" | sort | while read router; do
		echo "++ $router"
		echo "title = $router.$MYDOMAIN"
		echo "host = $router"
		echo ""
	done
}

make_smokeping_bare()
{
	while read router; do
		R=`echo $router|tr '.' '-'`
		echo "++ $R"
		echo "host = $router"
		echo ""
	done
}

find_gateways()
{
	echo 10.0.0.254
}

