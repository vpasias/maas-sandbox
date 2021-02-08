#!/bin/bash
wget https://raw.githubusercontent.com/charmed-kubernetes/bundle/master/overlays/calico-overlay.yaml
wget https://raw.githubusercontent.com/charmed-kubernetes/bundle/master/overlays/monitoring-pgt-overlay.yaml
#
juju deploy charmed-kubernetes --overlay /home/vagrant/maas-sandbox/cke/calico-overlay.yaml --overlay /home/vagrant/maas-sandbox/cke/monitoring-pgt-overlay.yaml
#
sudo snap install kubectl --classic
sudo snap install helm --classic  
