#!/bin/bash

TOPOLOGY="$1"

ASN=4200000000
V4_SUB="192.0.2."
V6_SUB="2001:DB8::"
INDEX="0"

HOSTS=`mktemp`

cat "$TOPOLOGY" | awk '{print $1}' | grep eth | awk -F':' '{print $1}' | sed 's/\"//g' | sort | uniq > $HOSTS
cat "$TOPOLOGY" | awk '{print $3}' | grep eth | awk -F':' '{print $1}' | sed 's/\"//g' | sort | uniq >> $HOSTS

for HOST in `cat $HOSTS | sort | uniq`
do
    HOST_VARS_FILE="host_vars/$HOST"
    cat > $HOST_VARS_FILE << EOF
---
fabric:
  asn: $ASN
  router_id: ${V4_SUB}${INDEX}
  loopback: ${V4_SUB}${INDEX}
  loopbackv6: ${V6_SUB}${INDEX}

interfaces:
EOF
    IFS_BACK="$IFS"
    IFS='
'
    for CONNECTION in `grep "\"$HOST\"" "$TOPOLOGY"`
    do
        SRC_HOST=`echo "$CONNECTION" | awk '{print $1}' | awk -F':' '{print $1}' | sed 's/\"//g'`
        SRC_INT=`echo "$CONNECTION" | awk '{print $1}' | awk -F':' '{print $2}' | sed 's/\"//g' | sed 's/eth//'`
        DEST_HOST=`echo "$CONNECTION" | awk '{print $3}' | awk -F':' '{print $1}' | sed 's/\"//g'`
        DEST_INT=`echo "$CONNECTION" | awk '{print $3}' | awk -F':' '{print $2}' | sed 's/\"//g' | sed 's/eth//' | sed 's/;//'`

        if [ "$SRC_HOST" == "$HOST" ]; then
            cat >> $HOST_VARS_FILE << EOF
  ${SRC_INT}:
    link: ${SRC_HOST}_${SRC_INT}
EOF
        else
            cat >> $HOST_VARS_FILE << EOF
  ${DEST_INT}:
    link: ${SRC_HOST}_${SRC_INT}
EOF
        fi
    done
    IFS="$IFS_BACK"
    ASN=$(($ASN + 1))
    INDEX=$(($INDEX + 1))
done

rm $HOSTS

exit 0

"spine-a.z":"eth0" -- "leaf-a.z":"eth0";

fabric:
  asn: 4200000000
  uplink_port_start: 1
  uplink_port_end: 6
  router_id: "192.0.2.0"
  loopback: 192.0.2.0
  loopbackv6: 2001:DB8::/128

interfaces:
  0:
    link: spine-a.z_0

  1:
    link: spine-a.z_1
# To create a network diagram:
# cat topology.dot | sed 's/:\"eth[0-9]\+\"//g' | dot -Tsvg > topology.svg
#

# To generate host_vars, run:
#   gen_host_vars.sh topology.dot

graph G {
    "isp-pe-1" -- "isp-pe-2";
    "isp-pe-2" -- "isp-pe-3";
    "isp-pe-3" -- "isp-pe-4";
    "isp-pe-4" -- "isp-pe-1";
    "isp-pe-1" -- "spine-a.z":"eth24";
    "isp-pe-2" -- "spine-b.z":"eth23";
    "isp-pe-2" -- "spine-a.y":"eth24";
    "isp-pe-3" -- "spine-b.y":"eth23";
    "isp-pe-3" -- "spine-a.x":"eth24";
    "isp-pe-4" -- "spine-b.x":"eth23";
    "isp-pe-4" -- "spine-a.w":"eth24";
    "isp-pe-1" -- "spine-b.w":"eth23";
    "spine-a.z":"eth0" -- "leaf-a.z":"eth0";
    "spine-a.z":"eth1" -- "leaf-b.z":"eth0";
    "spine-b.z":"eth0" -- "leaf-a.z":"eth1";
    "spine-b.z":"eth1" -- "leaf-b.z":"eth1";
    "spine-a.y":"eth0" -- "leaf-a.y":"eth0";
    "spine-a.y":"eth1" -- "leaf-b.y":"eth0";
    "spine-b.y":"eth0" -- "leaf-a.y":"eth1";
    "spine-b.y":"eth1" -- "leaf-b.y":"eth1";
    "spine-a.x":"eth0" -- "leaf-a.x":"eth0";
    "spine-a.x":"eth1" -- "leaf-b.x":"eth0";
    "spine-b.x":"eth0" -- "leaf-a.x":"eth1";
    "spine-b.x":"eth1" -- "leaf-b.x":"eth1";
    "spine-a.w":"eth0" -- "leaf-a.w":"eth0";
    "spine-a.w":"eth1" -- "leaf-b.w":"eth0";
    "spine-b.w":"eth0" -- "leaf-a.w":"eth1";
    "spine-b.w":"eth1" -- "leaf-b.w":"eth1";
    "leaf-a.z":"eth2" -- "slapd.z":"eth0";
    "leaf-b.z":"eth2" -- "slapd.z":"eth1";
    "leaf-a.y":"eth2" -- "slapd.y":"eth0";
    "leaf-b.y":"eth2" -- "slapd.y":"eth1";
    "leaf-a.z":"eth3" -- "postgres.z":"eth0";
    "leaf-b.z":"eth3" -- "postgres.z":"eth1";
    "leaf-a.y":"eth3" -- "postgres.y":"eth0";
    "leaf-b.y":"eth3" -- "postgres.y":"eth1";
    "leaf-a.z":"eth4" -- "kerb-auth.z":"eth0";
    "leaf-b.z":"eth4" -- "kerb-auth.z":"eth1";
    "leaf-a.y":"eth4" -- "kerb-auth.y":"eth0";
    "leaf-b.y":"eth4" -- "kerb-auth.y":"eth1";
    "leaf-a.z":"eth5" -- "postfix.z":"eth0";
    "leaf-b.z":"eth5" -- "postfix.z":"eth1";
    "leaf-a.y":"eth5" -- "postfix.y":"eth0";
    "leaf-b.y":"eth5" -- "postfix.y":"eth1";
    "leaf-a.z":"eth6" -- "cyrus-fe.z":"eth0";
    "leaf-b.z":"eth6" -- "cyrus-fe.z":"eth1";
    "leaf-a.y":"eth6" -- "cyrus-fe.y":"eth0";
    "leaf-b.y":"eth6" -- "cyrus-fe.y":"eth1";
    "leaf-a.z":"eth7" -- "cyrus-be-1.z":"eth0";
    "leaf-b.z":"eth7" -- "cyrus-be-1.z":"eth1";
    "leaf-a.y":"eth7" -- "cyrus-be-1.y":"eth0";
    "leaf-b.y":"eth7" -- "cyrus-be-1.y":"eth1";
    "leaf-a.z":"eth8" -- "cyrus-be-2.z":"eth0";
    "leaf-b.z":"eth8" -- "cyrus-be-2.z":"eth1";
    "leaf-a.y":"eth8" -- "cyrus-be-2.y":"eth0";
    "leaf-b.y":"eth8" -- "cyrus-be-2.y":"eth1";
    "leaf-a.z":"eth9" -- "nfs.z":"eth0";
    "leaf-b.z":"eth9" -- "nfs.z":"eth1";
    "leaf-a.y":"eth9" -- "nfs.y":"eth0";
    "leaf-b.y":"eth9" -- "nfs.y":"eth1";
    "leaf-a.z":"eth10" -- "nfs-backup.z":"eth0";
    "leaf-b.z":"eth10" -- "nfs-backup.z":"eth1";
    "leaf-a.y":"eth10" -- "nfs-backup.y":"eth0";
    "leaf-b.y":"eth10" -- "nfs-backup.y":"eth1";
    "leaf-a.z":"eth11" -- "cyrus-mu.z":"eth0";
    "leaf-b.z":"eth11" -- "cyrus-mu.z":"eth1";
    "leaf-a.y":"eth11" -- "cyrus-mu.y":"eth0";
    "leaf-b.y":"eth11" -- "cyrus-mu.y":"eth1";
    "leaf-a.z":"eth12" -- "nginx.z":"eth0";
    "leaf-b.z":"eth12" -- "nginx.z":"eth1";
    "leaf-a.y":"eth12" -- "nginx.y":"eth0";
    "leaf-b.y":"eth12" -- "nginx.y":"eth1";
    "leaf-a.z":"eth13" -- "freeswitch.z":"eth0";
    "leaf-b.z":"eth13" -- "freeswitch.z":"eth1";
    "leaf-a.y":"eth13" -- "freeswitch.y":"eth0";
    "leaf-b.y":"eth13" -- "freeswitch.y":"eth1";
    "leaf-a.w":"eth2" -- "neo.w":"eth0";
    "leaf-b.w":"eth2" -- "neo.w":"eth1";
    "leaf-a.w":"eth3" -- "morpheus.w":"eth0";
    "leaf-b.w":"eth3" -- "morpheus.w":"eth1";
    "leaf-a.w":"eth4" -- "trinity.w":"eth0";
    "leaf-b.w":"eth4" -- "trinity.w":"eth1";
    "leaf-a.w":"eth5" -- "alexander.w":"eth0";
    "leaf-b.w":"eth5" -- "alexander.w":"eth1";
    "leaf-a.w":"eth6" -- "graham.w":"eth0";
    "leaf-b.w":"eth6" -- "graham.w":"eth1";
    "leaf-a.w":"eth7" -- "bell.w":"eth0";
    "leaf-b.w":"eth7" -- "bell.w":"eth1";
    "leaf-a.x":"eth2" -- "eros.x":"eth0";
    "leaf-b.x":"eth2" -- "eros.x":"eth1";
    "leaf-a.x":"eth3" -- "anteros.x":"eth0";
    "leaf-b.x":"eth3" -- "anteros.x":"eth1";
}
