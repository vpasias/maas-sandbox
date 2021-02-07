#!/bin/bash
juju deploy --config config/masakari.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:masakari masakari
juju deploy --config config/masakari.yaml cs:hacluster masakari-hacluster
juju deploy cs:cinder-ceph cinder-ceph
juju add-relation cinder:ha cinder-hacluster:ha
#
juju deploy mysql-router cinder-mysql-router
juju add-relation cinder-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation cinder-mysql-router:shared-db cinder:shared-db
!
juju add-relation cinder:identity-service keystone:identity-service
juju add-relation cinder:amqp rabbitmq-server:amqp
#
juju add-relation cinder:image-service glance:image-service
#
juju add-relation cinder-ceph:storage-backend cinder:storage-backend
juju add-relation cinder-ceph:ceph ceph-mon:client
#
juju add-relation cinder:certificates vault:certificates
