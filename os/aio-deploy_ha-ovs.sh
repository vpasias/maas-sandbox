#!/bin/bash
# Deploy juju controller and add machines first. Execute first:
# ./00200-create-juju-bootstrap-controller.sh
# ./00300-add-machines.sh
# deploy ceph osd
juju deploy --config config/ceph-osd.yaml -n 3 --to 6,7,8 cs:ceph-osd ceph-osd
#
sleep 10
# deploy ceph osd backup
juju deploy --config config/ceph-osd-backup.yaml -n 3 --to 9,10,11 cs:ceph-osd ceph-osd-backup
#
sleep 10
# deploy ceph mon
juju deploy --config config/ceph-mon.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:ceph-mon ceph-mon
juju add-relation ceph-mon:osd ceph-osd:mon
#
sleep 10
# deploy ceph mon backup
juju deploy --config config/ceph-mon-backup.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:ceph-mon ceph-mon-backup
juju add-relation ceph-mon-backup:osd ceph-osd-backup:mon
#
sleep 10
# deploy rabbitmq server
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 cs:rabbitmq-server rabbitmq-server
#
sleep 10
# deploy memcached
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 cs:memcached memcached
#
sleep 10
# deploy percona cluster mysql
juju deploy --config config/pcmysql.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:percona-cluster mysql
juju deploy --config config/pcmysql.yaml cs:hacluster mysql-hacluster
juju add-relation mysql:ha mysql-hacluster:ha
sleep 10
# deploy keystone
juju deploy --config config/keystone.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:keystone keystone
juju deploy --config config/keystone.yaml cs:hacluster keystone-hacluster
juju add-relation keystone:ha keystone-hacluster:ha
#
juju add-relation keystone:shared-db mysql:shared-db
#
sleep 10
# deploy ceph radosgw
juju deploy --config config/ceph-radosgw.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:ceph-radosgw ceph-radosgw
juju deploy --config config/ceph-radosgw.yaml cs:hacluster ceph-radosgw-hacluster
juju add-relation ceph-radosgw:mon ceph-mon:radosgw
juju add-relation ceph-radosgw:ha ceph-radosgw-hacluster:ha
juju add-relation ceph-radosgw:identity-service keystone:identity-service
#
sleep 10
#deploy-glance
juju deploy --config config/glance.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:glance glance
juju deploy --config config/glance.yaml cs:hacluster glance-hacluster
juju add-relation glance:ha glance-hacluster:ha
#
juju add-relation glance:shared-db mysql:shared-db
juju add-relation glance:identity-service keystone:identity-service
juju add-relation glance:amqp rabbitmq-server:amqp
#
juju add-relation glance:ceph ceph-mon:client
#
sleep 10
#deploy cinder
juju deploy --config config/cinder.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:cinder cinder
juju deploy --config config/cinder.yaml cs:hacluster cinder-hacluster
juju deploy cs:cinder-ceph cinder-ceph
juju add-relation cinder:ha cinder-hacluster:ha
#
juju add-relation cinder:shared-db mysql:shared-db
juju add-relation cinder:identity-service keystone:identity-service
juju add-relation cinder:amqp rabbitmq-server:amqp
#
juju add-relation cinder:image-service glance:image-service
#
juju add-relation cinder-ceph:storage-backend cinder:storage-backend
juju add-relation cinder-ceph:ceph ceph-mon:client
#
sleep 10
# deploy cinder backup
juju deploy cs:~openstack-charmers/cinder-backup cinder-backup
#
juju add-relation cinder-backup:backup-backend cinder:backup-backend
juju add-relation cinder-backup:ceph ceph-mon-backup:client
#
sleep 10
# deploy nova cloud controller
juju deploy --config config/nova-cloud-controller.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:nova-cloud-controller nova-cloud-controller
juju deploy --config config/nova-cloud-controller.yaml cs:hacluster ncc-hacluster
juju add-relation nova-cloud-controller:ha ncc-hacluster:ha
#
juju add-relation nova-cloud-controller:shared-db mysql:shared-db
juju add-relation nova-cloud-controller:identity-service keystone:identity-service
juju add-relation nova-cloud-controller:amqp rabbitmq-server:amqp
#
juju add-relation nova-cloud-controller:memcache memcached:cache
juju add-relation nova-cloud-controller:image-service glance:image-service
juju add-relation nova-cloud-controller:cinder-volume-service cinder:cinder-volume-service
#
sleep 10
# deploy nova compute
juju deploy --config config/nova-compute.yaml -n 3 --to 3,4,5 cs:nova-compute nova-compute
#
juju add-relation nova-compute:cloud-compute nova-cloud-controller:cloud-compute
juju add-relation nova-compute:amqp rabbitmq-server:amqp
juju add-relation nova-compute:image-service glance:image-service
juju add-relation nova-compute:ceph ceph-mon:client
juju add-relation nova-compute:ceph-access cinder-ceph:ceph-access
#
sleep 10
# deploy placement
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --config openstack-origin=cloud:focal-victoria cs:placement placement
juju deploy cs:hacluster placement-hacluster
juju add-relation placement:ha placement-hacluster:ha
#
juju add-relation placement mysql
juju add-relation placement keystone
juju add-relation placement nova-cloud-controller
#
sleep 10
# deploy neutron
juju deploy --config config/neutron-ovs.yaml -n 3 --to 0,1,2 cs:neutron-gateway neutron-gateway
juju deploy --config config/neutron-ovs.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:neutron-api neutron-api
juju deploy cs:neutron-openvswitch neutron-openvswitch
#
juju deploy --config config/neutron-ovs.yaml cs:hacluster neutron-hacluster
juju add-relation neutron-api:ha neutron-hacluster:ha
#
juju add-relation neutron-gateway:quantum-network-service nova-cloud-controller:quantum-network-service
juju add-relation neutron-gateway:amqp rabbitmq-server:amqp
#
juju add-relation neutron-api:shared-db mysql:shared-db
juju add-relation neutron-api:identity-service keystone:identity-service
juju add-relation neutron-api:amqp rabbitmq-server:amqp
#
juju add-relation neutron-api:neutron-plugin-api neutron-gateway:neutron-plugin-api
juju add-relation neutron-api:neutron-plugin-api neutron-openvswitch:neutron-plugin-api
juju add-relation neutron-api:neutron-api nova-cloud-controller:neutron-api
#
juju add-relation neutron-openvswitch:amqp rabbitmq-server:amqp
juju add-relation neutron-openvswitch:neutron-plugin nova-compute:neutron-plugin
#
sleep 10
# deploy openstack dashboard
juju deploy --config config/openstack-dashboard.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:openstack-dashboard openstack-dashboard
juju deploy --config config/openstack-dashboard.yaml cs:hacluster openstack-dashboard-hacluster
juju add-relation openstack-dashboard:ha openstack-dashboard-hacluster:ha
#
juju add-relation openstack-dashboard:shared-db mysql:shared-db
juju add-relation openstack-dashboard:identity-service keystone:identity-service
#
sleep 10
# deploy ntp
juju deploy --config config/ntp.yaml cs:ntp ntp
juju add-relation ntp:juju-info ceph-osd:juju-info
juju add-relation ntp:juju-info ceph-osd-backup:juju-info
juju add-relation ntp:juju-info nova-compute:juju-info
juju add-relation ntp:juju-info neutron-gateway:juju-info
#
sleep 10
# deploy nagios
juju deploy --config config/nagios.yaml -n 1 --to lxd:12 cs:nagios nagios
juju deploy --config config/nagios.yaml cs:ntp nagios-ntp
juju deploy cs:nrpe nrpe
juju add-relation nagios:juju-info nagios-ntp:juju-info
juju add-relation nagios:monitors nrpe:monitors
juju add-relation nrpe:nrpe-external-master ceph-mon:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ceph-mon-backup:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ceph-osd:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ceph-osd-backup:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ceph-radosgw:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ceph-radosgw-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master cinder:nrpe-external-master
juju add-relation nrpe:nrpe-external-master cinder-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master glance:nrpe-external-master
juju add-relation nrpe:nrpe-external-master glance-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master keystone:nrpe-external-master
juju add-relation nrpe:nrpe-external-master keystone-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master memcached:nrpe-external-master
juju add-relation nrpe:nrpe-external-master mysql:nrpe-external-master
juju add-relation nrpe:nrpe-external-master mysql-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ncc-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master neutron-api:nrpe-external-master
juju add-relation nrpe:nrpe-external-master neutron-gateway:nrpe-external-master
juju add-relation nrpe:nrpe-external-master neutron-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master nova-cloud-controller:nrpe-external-master
juju add-relation nrpe:nrpe-external-master nova-compute:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ntp:nrpe-external-master
juju add-relation nrpe:nrpe-external-master openstack-dashboard:nrpe-external-master
juju add-relation nrpe:nrpe-external-master openstack-dashboard-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master rabbitmq-server:nrpe-external-master
#
sleep 10
# deploy masakari
juju deploy --config config/masakari.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:masakari masakari
juju deploy --config config/masakari.yaml cs:hacluster masakari-hacluster
juju deploy --config config/masakari.yaml cs:pacemaker-remote pacemaker-remote
juju deploy cs:masakari-monitors masakari-monitors
#
juju add-relation masakari:ha masakari-hacluster:ha
#
juju add-relation masakari:shared-db mysql:shared-db
#
juju add-relation masakari:identity-service keystone:identity-service
juju add-relation masakari:amqp rabbitmq-server:amqp
#
juju add-relation nova-compute:juju-info masakari-monitors:container
#
juju add-relation keystone:identity-credentials masakari-monitors:identity-credentials
#
juju add-relation nova-compute:juju-info pacemaker-remote:juju-info
#
juju add-relation masakari-hacluster:pacemaker-remote pacemaker-remote:pacemaker-remote
#
sleep 10
