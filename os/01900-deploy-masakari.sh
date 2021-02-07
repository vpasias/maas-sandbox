#!/bin/bash
juju deploy --config config/masakari.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:masakari masakari
juju deploy --config config/masakari.yaml cs:hacluster masakari-hacluster
juju deploy cs:masakari-monitors masakari-monitors 
#
juju deploy mysql-router masakari-mysql-router
juju add-relation masakari-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation masakari-mysql-router:shared-db cinder:shared-db
!
juju add-relation masakari:identity-service keystone:identity-service
juju add-relation masakari:amqp rabbitmq-server:amqp

