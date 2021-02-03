#!/bin/bash
#

juju switch maas-cloud-controller:openstack

cat << EOF |  tee ceph-osd.yaml
ceph-osd:
  osd-devices: /dev/sdb
  source: cloud:focal-victoria
EOF

juju deploy -n 6 --config ceph-osd.yaml ceph-osd

cat << EOF |  tee nova-compute.yaml
nova-compute:
  enable-live-migration: true
  enable-resize: true
  migration-auth-type: ssh
  openstack-origin: cloud:focal-victoria
EOF

juju deploy -n 3 --to 3,4,5 --config nova-compute.yaml nova-compute

juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 mysql-innodb-cluster

juju deploy --to lxd:3 vault

juju deploy mysql-router vault-mysql-router && juju add-relation vault-mysql-router:db-router mysql-innodb-cluster:db-router && juju add-relation vault-mysql-router:shared-db vault:shared-db

cat << EOF |  tee neutron.yaml
ovn-chassis:
  bridge-interface-mappings: br-ex:ens6
  ovn-bridge-mappings: physnet1:br-ex
neutron-api:
  neutron-security-groups: true
  flat-network-providers: physnet1
  openstack-origin: cloud:focal-victoria
ovn-central:
  source: cloud:focal-victoria
EOF

juju deploy -n 6 --to lxd:0,lxd:1,lxd:2,lxd:3,lxd:4,lxd:5 --config neutron.yaml ovn-central
#juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --config neutron.yaml ovn-central && juju add-unit -n 3 --to lxd:3,lxd:4,lxd:5 ovn-central

juju deploy --to lxd:1 --config neutron.yaml neutron-api

juju deploy neutron-api-plugin-ovn && juju deploy --config neutron.yaml ovn-chassis

juju add-relation neutron-api-plugin-ovn:neutron-plugin neutron-api:neutron-plugin-api-subordinate && \
juju add-relation neutron-api-plugin-ovn:ovsdb-cms ovn-central:ovsdb-cms && \
juju add-relation ovn-chassis:ovsdb ovn-central:ovsdb && \
juju add-relation ovn-chassis:nova-compute nova-compute:neutron-plugin && \
juju add-relation neutron-api:certificates vault:certificates && \
juju add-relation neutron-api-plugin-ovn:certificates vault:certificates && \
juju add-relation ovn-central:certificates vault:certificates && \
juju add-relation ovn-chassis:certificates vault:certificates

juju deploy mysql-router neutron-api-mysql-router && \
juju add-relation neutron-api-mysql-router:db-router mysql-innodb-cluster:db-router && \
juju add-relation neutron-api-mysql-router:shared-db neutron-api:shared-db

juju deploy --to lxd:0 --config openstack-origin=cloud:focal-victoria keystone

juju deploy mysql-router keystone-mysql-router && juju add-relation keystone-mysql-router:db-router mysql-innodb-cluster:db-router && \
juju add-relation keystone-mysql-router:shared-db keystone:shared-db

juju add-relation keystone:identity-service neutron-api:identity-service && juju add-relation keystone:certificates vault:certificates

juju deploy --to lxd:2 rabbitmq-server

juju add-relation rabbitmq-server:amqp neutron-api:amqp && juju add-relation rabbitmq-server:amqp nova-compute:amqp

cat << EOF |  tee nova-cloud-controller.yaml
nova-cloud-controller:
  network-manager: Neutron
  openstack-origin: cloud:focal-victoria
EOF

juju deploy --to lxd:3 --config nova-cloud-controller.yaml nova-cloud-controller

juju deploy mysql-router ncc-mysql-router && juju add-relation ncc-mysql-router:db-router mysql-innodb-cluster:db-router && \
juju add-relation ncc-mysql-router:shared-db nova-cloud-controller:shared-db

juju add-relation nova-cloud-controller:identity-service keystone:identity-service && juju add-relation nova-cloud-controller:amqp rabbitmq-server:amqp && \
juju add-relation nova-cloud-controller:neutron-api neutron-api:neutron-api && juju add-relation nova-cloud-controller:cloud-compute nova-compute:cloud-compute && \
juju add-relation nova-cloud-controller:certificates vault:certificates

juju deploy --to lxd:3 --config openstack-origin=cloud:focal-victoria placement

juju deploy mysql-router placement-mysql-router && juju add-relation placement-mysql-router:db-router mysql-innodb-cluster:db-router && \
juju add-relation placement-mysql-router:shared-db placement:shared-db

juju add-relation placement:identity-service keystone:identity-service && juju add-relation placement:placement nova-cloud-controller:placement && \
juju add-relation placement:certificates vault:certificates

juju deploy --to lxd:2 --config openstack-origin=cloud:focal-victoria openstack-dashboard

juju deploy mysql-router dashboard-mysql-router && juju add-relation dashboard-mysql-router:db-router mysql-innodb-cluster:db-router && \
juju add-relation dashboard-mysql-router:shared-db openstack-dashboard:shared-db

juju add-relation openstack-dashboard:identity-service keystone:identity-service && juju add-relation openstack-dashboard:certificates vault:certificates

juju deploy --to lxd:3 --config openstack-origin=cloud:focal-victoria glance

juju deploy mysql-router glance-mysql-router && juju add-relation glance-mysql-router:db-router mysql-innodb-cluster:db-router && \
juju add-relation glance-mysql-router:shared-db glance:shared-db

juju add-relation glance:image-service nova-cloud-controller:image-service && juju add-relation glance:image-service nova-compute:image-service && \
juju add-relation glance:identity-service keystone:identity-service && \
juju add-relation glance:certificates vault:certificates

juju deploy -n 6 --to lxd:0,lxd:1,lxd:2,lxd:3,lxd:4,lxd:5 --config source=cloud:focal-victoria ceph-mon

juju add-relation ceph-mon:osd ceph-osd:mon && juju add-relation ceph-mon:client nova-compute:ceph && juju add-relation ceph-mon:client glance:ceph

cat << EOF |  tee cinder.yaml
cinder:
  glance-api-version: 2
  block-device: None
  openstack-origin: cloud:focal-victoria
EOF

juju deploy --to lxd:1 --config cinder.yaml cinder

juju deploy mysql-router cinder-mysql-router && juju add-relation cinder-mysql-router:db-router mysql-innodb-cluster:db-router && juju add-relation cinder-mysql-router:shared-db cinder:shared-db

juju add-relation cinder:cinder-volume-service nova-cloud-controller:cinder-volume-service && juju add-relation cinder:identity-service keystone:identity-service && \
juju add-relation cinder:amqp rabbitmq-server:amqp && juju add-relation cinder:image-service glance:image-service && juju add-relation cinder:certificates vault:certificates

juju deploy cinder-ceph

juju add-relation cinder-ceph:storage-backend cinder:storage-backend && juju add-relation cinder-ceph:ceph ceph-mon:client && juju add-relation cinder-ceph:ceph-access nova-compute:ceph-access

juju deploy --to lxd:0 ceph-radosgw

juju add-relation ceph-radosgw:mon ceph-mon:radosgw

juju deploy ntp

juju add-relation ceph-osd:juju-info ntp:juju-info
#
