juju add-unit -n 2 kubeapi-load-balancer
juju deploy hacluster
juju config kubeapi-load-balancer ha-cluster-vip="192.168.10.231 192.168.10.232"
juju relate kubeapi-load-balancer hacluster
#
juju scp kubernetes-master/0:config ~/.kube/config
