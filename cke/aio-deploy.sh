#!/bin/bash
wget https://raw.githubusercontent.com/charmed-kubernetes/bundle/master/overlays/calico-overlay.yaml
#wget https://raw.githubusercontent.com/charmed-kubernetes/bundle/master/overlays/monitoring-pgt-overlay.yaml
#wget https://raw.githubusercontent.com/charmed-kubernetes/bundle/master/overlays/logging-egf-overlay.yaml
#
juju deploy ./bundle.yaml --overlay ./calico-overlay.yaml --overlay ./monitoring-overlay.yaml --overlay ./logging-overlay.yaml --map-machines=existing
# juju deploy bundle.yaml --overlay calico-overlay.yaml --overlay monitoring-overlay.yaml 
#
sudo snap install kubectl --classic
sudo snap install helm --classic
#
sleep 10
#
juju add-unit -n 2 --to 8,9 kubeapi-load-balancer
juju deploy hacluster
juju config kubeapi-load-balancer ha-cluster-vip="192.168.10.231 192.168.10.232"
juju relate kubeapi-load-balancer hacluster
#
juju config kubernetes-master enable-metrics=true
#
sleep 10
#
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
sleep 10
#
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
sleep 10
#
wget https://raw.githubusercontent.com/charmed-kubernetes/kubernetes-docs/master/assets/graylog-vhost.tmpl
juju config apache2 vhost_http_template="$(base64 ~/maas-sandbox/cke/graylog-vhost.tmpl)"
#
sleep 10
