#!/bin/bash
juju deploy --config config/glance.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:glance glance
juju deploy --config config/glance.yaml cs:hacluster glance-hacluster
juju add-relation glance:ha glance-hacluster:ha
#
juju deploy mysql-router glance-mysql-router
juju add-relation glance-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation glance-mysql-router:shared-db glance:shared-db
#
juju add-relation glance:identity-service keystone:identity-service
juju add-relation glance:amqp rabbitmq-server:amqp
#
juju add-relation glance:ceph ceph-mon:client
