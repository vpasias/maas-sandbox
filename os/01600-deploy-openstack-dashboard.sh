#!/bin/bash
juju deploy --config config/openstack-dashboard.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:openstack-dashboard openstack-dashboard
juju deploy --config config/openstack-dashboard.yaml cs:hacluster openstack-dashboard-hacluster
juju add-relation openstack-dashboard:ha openstack-dashboard-hacluster:ha
#
juju deploy mysql-router dashboard-mysql-router
juju add-relation dashboard-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation dashboard-mysql-router:shared-db openstack-dashboard:shared-db
#
juju add-relation openstack-dashboard:identity-service keystone:identity-service
#
juju add-relation openstack-dashboard:certificates vault:certificates
