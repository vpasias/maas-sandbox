#!/bin/bash
wget https://raw.githubusercontent.com/charmed-kubernetes/bundle/master/overlays/calico-overlay.yaml
#wget https://raw.githubusercontent.com/charmed-kubernetes/bundle/master/overlays/monitoring-pgt-overlay.yaml
#wget https://raw.githubusercontent.com/charmed-kubernetes/bundle/master/overlays/logging-egf-overlay.yaml
#
juju deploy bundle.yaml --overlay calico-overlay.yaml --overlay monitoring-overlay.yaml --overlay logging-overlay.yaml
# juju deploy bundle.yaml --overlay calico-overlay.yaml --overlay monitoring-overlay.yaml 
#
sudo snap install kubectl --classic
sudo snap install helm --classic
