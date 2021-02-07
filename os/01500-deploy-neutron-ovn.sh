#!/bin/bash
juju deploy --config config/neutron-ovn.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:ovn-central ovn-central
juju deploy --config config/neutron-ovn.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:neutron-api neutron-api
juju deploy --config config/neutron-ovn.yaml cs:ovn-chassis ovn-chassis
juju deploy cs:neutron-api-plugin-ovn neutron-api-plugin-ovn
#
juju deploy --config config/neutron-ovn.yaml cs:hacluster neutron-hacluster
juju add-relation neutron-api:ha neutron-hacluster:ha
#
juju add-relation neutron-api-plugin-ovn:neutron-plugin neutron-api:neutron-plugin-api-subordinate
juju add-relation neutron-api-plugin-ovn:ovsdb-cms ovn-central:ovsdb-cms
juju add-relation ovn-chassis:ovsdb ovn-central:ovsdb
juju add-relation ovn-chassis:nova-compute nova-compute:neutron-plugin
juju add-relation neutron-api:certificates vault:certificates
juju add-relation neutron-api-plugin-ovn:certificates vault:certificates
juju add-relation ovn-central:certificates vault:certificates
juju add-relation ovn-chassis:certificates vault:certificates
#
juju deploy mysql-router neutron-api-mysql-router
juju add-relation neutron-api-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation neutron-api-mysql-router:shared-db neutron-api:shared-db
#
juju add-relation keystone:identity-service neutron-api:identity-service
juju add-relation rabbitmq-server:amqp neutron-api:amqp
