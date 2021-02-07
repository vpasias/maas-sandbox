#!/bin/bash
juju deploy --config config/masakari.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:masakari masakari
juju deploy --config config/masakari.yaml cs:hacluster masakari-hacluster
juju deploy cs:masakari-monitors masakari-monitors
juju add-relation masakari:ha masakari-hacluster:ha
#
juju deploy mysql-router masakari-mysql-router
juju add-relation masakari-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation masakari-mysql-router:shared-db masakari:shared-db
#
juju add-relation masakari:identity-service keystone:identity-service
juju add-relation masakari:amqp rabbitmq-server:amqp
#
juju add-relation nova-compute:juju-info masakari-monitors:container
#
juju add-relation keystone:identity-credentials masakari-monitors:identity-credentials
#
juju add-relation nova-compute:juju-info pacemaker-remote:juju-info
