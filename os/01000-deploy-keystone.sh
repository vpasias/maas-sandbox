#!/bin/bash
juju deploy --config config/keystone.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:keystone keystone
juju deploy --config config/keystone.yaml cs:hacluster keystone-hacluster
juju add-relation keystone:ha keystone-hacluster:ha
#
juju add-relation keystone:shared-db mysql:shared-db
juju add-relation keystone:identity-service cinder:identity-service
#
juju deploy mysql-router keystone-mysql-router
juju add-relation keystone-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation keystone-mysql-router:shared-db keystone:shared-db
#
juju add-relation keystone:identity-service neutron-api:identity-service
juju add-relation keystone:certificates vault:certificates
