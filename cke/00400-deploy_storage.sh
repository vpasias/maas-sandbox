#!/bin/bash
juju deploy -n 3 ceph-osd --storage osd-devices=32G,2 --storage osd-journals=8G,1
#
juju deploy -n 3 --to lxd:4,lxd:5,lxd:6 cs:ceph-mon ceph-mon
juju add-relation ceph-osd ceph-mon
#
juju deploy -n 3 --to lxd:4,lxd:6,lxd:6 cs:ceph-fs ceph-fs
juju add-relation ceph-fs ceph-mon
#
juju add-relation ceph-mon:admin kubernetes-master
juju add-relation ceph-mon:client kubernetes-master
#
kubectl get sc,po
