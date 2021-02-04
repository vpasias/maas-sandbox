#!/bin/bash
juju deploy --series focal --config openstack-origin=cloud:focal-victoria cs:placement
#
juju add-relation placement mysql
juju add-relation placement keystone
juju add-relation placement nova-cloud-controller
