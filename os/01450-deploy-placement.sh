#!/bin/bash
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --config openstack-origin=cloud:focal-victoria cs:placement placement
juju deploy cs:hacluster placement-hacluster
juju add-relation placement:ha placement-hacluster:ha
#
juju add-relation placement mysql
juju add-relation placement keystone
juju add-relation placement nova-cloud-controller
