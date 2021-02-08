juju deploy charmed-kubernetes --overlay calico-overlay.yaml
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
