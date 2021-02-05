#!/bin/bash
juju deploy --config config/mysql.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:mysql-innodb-cluster mysql-innodb-cluster
