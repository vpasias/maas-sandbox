#!/bin/bash
juju deploy -n 1 --to lxd:0 --series=bionic cs:nagios nagios
juju deploy nrpe --series=bionic
juju expose nagios
#
juju add-relation nagios nrpe
#
juju add-relation nrpe kubernetes-master
juju add-relation nrpe kubernetes-worker
juju add-relation nrpe etcd
juju add-relation nrpe easyrsa
juju add-relation nrpe kubeapi-load-balancer
#
juju status --format yaml nagios/0 | grep public-address
#
juju ssh nagios/0 sudo cat /var/lib/juju/nagios.passwd
