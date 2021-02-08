#!/bin/bash
wget https://raw.githubusercontent.com/charmed-kubernetes/bundle/master/overlays/calico-overlay.yaml
wget https://raw.githubusercontent.com/charmed-kubernetes/bundle/master/overlays/monitoring-pgt-overlay.yaml
#
juju deploy charmed-kubernetes --overlay /home/vagrant/calico-overlay.yaml --overlay /home/vagrant/monitoring-pgt-overlay.yaml
#
sudo snap install kubectl --classic
#
juju scp kubernetes-master/0:config ~/.kube/config
#
kubectl cluster-info
#
kubectl get pods
#
kubectl get services
#
juju run-action --wait grafana/0 get-login-info
#
juju config kubernetes-master enable-metrics=true
