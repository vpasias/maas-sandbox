#!/bin/bash
juju deploy --config ceph-osd.yaml -n 3 --to 10,11,12 cs:ceph-osd ceph-osd
#
juju deploy -n 3 --to lxd:1,lxd:2,lxd:3 cs:ceph-mon ceph-mon
juju add-relation ceph-osd ceph-mon
#
juju deploy -n 3 --to lxd:1,lxd:2,lxd:3 cs:ceph-fs ceph-fs
juju add-relation ceph-fs ceph-mon
#
juju add-relation ceph-mon:admin kubernetes-master
juju add-relation ceph-mon:client kubernetes-master
#
#kubectl get sc,po
