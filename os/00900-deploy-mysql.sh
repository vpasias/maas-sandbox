#!/bin/bash
juju deploy --config config/mysql.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:mysql-innodb-cluster mysql-innodb-cluster
juju deploy mysql-router keystone-mysql-router
juju add-relation keystone-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation keystone-mysql-router:shared-db keystone:shared-db
