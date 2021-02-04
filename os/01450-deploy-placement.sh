#!/bin/bash
juju deploy --to lxd:0 --config openstack-origin=cloud:focal-victoria cs:placement placement
#
juju add-relation placement mysql
juju add-relation placement keystone
juju add-relation placement nova-cloud-controller
