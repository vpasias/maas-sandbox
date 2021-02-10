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
#
