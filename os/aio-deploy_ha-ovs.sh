#!/bin/bash
# create juju bootstrap controller
juju bootstrap --to node01.maas --config default-series=focal maas-cloud maas-cloud-controller
sleep 20
juju add-model --config default-series=focal openstack
sleep 10
# add machines
juju add-machine node02.maas
juju add-machine node03.maas
juju add-machine node04.maas
juju add-machine node05.maas
juju add-machine node06.maas
juju add-machine node07.maas
juju add-machine node08.maas
juju add-machine node09.maas
juju add-machine node10.maas
juju add-machine node11.maas
juju add-machine node12.maas
juju add-machine node13.maas
juju add-machine node14.maas
sleep 600
juju machines
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
#deploy mysql
juju deploy --config config/pcmysql.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:percona-cluster mysql
juju deploy --config config/pcmysql.yaml cs:hacluster mysql-hacluster
juju add-relation mysql:ha mysql-hacluster:ha
