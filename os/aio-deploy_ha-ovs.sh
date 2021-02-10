#!/bin/bash
# Deploy juju controller and add machines first. Execute first:
# ./00200-create-juju-bootstrap-controller.sh
# ./00300-add-machines.sh
#deploy ceph
juju deploy --config config/ceph-osd.yaml -n 3 --to 6,7,8 cs:ceph-osd ceph-osd
sleep 10
#deploy ceph osd backup
juju deploy --config config/ceph-osd-backup.yaml -n 3 --to 9,10,11 cs:ceph-osd ceph-osd-backup
sleep 10
#deploy ceph mon
juju deploy --config config/ceph-mon.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:ceph-mon ceph-mon
juju add-relation ceph-mon:osd ceph-osd:mon
sleep 10
#deploy rabbitmq server
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 cs:rabbitmq-server rabbitmq-server
#deploy memcached
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 cs:memcached memcached
#deploy percona cluster mysql
juju deploy --config config/pcmysql.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:percona-cluster mysql
juju deploy --config config/pcmysql.yaml cs:hacluster mysql-hacluster
juju add-relation mysql:ha mysql-hacluster:ha
sleep 10
# deploy keystone
juju deploy --config config/keystone.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:keystone keystone
juju deploy --config config/keystone.yaml cs:hacluster keystone-hacluster
juju add-relation keystone:ha keystone-hacluster:ha
#
juju add-relation keystone:shared-db mysql:shared-db
