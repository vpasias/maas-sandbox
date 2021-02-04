#!/bin/bash
juju deploy --config config/keystone.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:keystone keystone
juju deploy --config config/keystone.yaml cs:hacluster keystone-hacluster
juju add-relation keystone:ha keystone-hacluster:ha
#
juju add-relation keystone:shared-db mysql:shared-db
#juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --config vip=192.168.10.231 keystone
#juju deploy --config cluster_count=3 hacluster keystone-hacluster
#juju add-relation keystone-hacluster:ha keystone:ha
