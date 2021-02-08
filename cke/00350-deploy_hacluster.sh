juju add-unit -n 2 kubeapi-load-balancer
juju deploy hacluster
juju config kubeapi-load-balancer ha-cluster-vip="192.168.10.231 192.168.10.232"
juju relate kubeapi-load-balancer hacluster
#
mkdir ~/.kube
juju scp kubernetes-master/0:config ~/.kube/config
#
kubectl cluster-info
#
kubectl get nodes
#
kubectl get pods
#
kubectl get services
#
juju run-action --wait grafana/0 get-login-info
#
juju config kubernetes-master enable-metrics=true
