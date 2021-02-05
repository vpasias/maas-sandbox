#!/bin/bash
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --config openstack-origin=cloud:focal-victoria cs:placement placement
juju deploy cs:hacluster placement-hacluster
juju add-relation placement:ha placement-hacluster:ha
#
juju deploy mysql-router placement-mysql-router
juju add-relation placement-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation placement-mysql-router:shared-db placement:shared-db
#
juju add-relation placement:identity-service keystone:identity-service
juju add-relation placement:placement nova-cloud-controller:placement
#
juju add-relation placement:certificates vault:certificates
