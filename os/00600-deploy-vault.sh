#!/bin/bash
juju deploy --config config/vault.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:percona-cluster mysql
juju deploy --config config/vault.yaml cs:hacluster mysql-hacluster
juju add-relation mysql:ha mysql-hacluster:ha
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --config vip=192.168.10.240 cs:vault vault
juju deploy --config cluster_count=3 hacluster vault-hacluster
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 etcd
juju deploy --to lxd:0 cs:~containers/easyrsa
juju add-relation vault:ha vault-hacluster:ha
juju add-relation vault:shared-db percona-cluster:shared-db
juju add-relation etcd:db vault:etcd
juju add-relation etcd:certificates easyrsa:client
