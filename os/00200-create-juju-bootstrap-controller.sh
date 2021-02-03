#!/bin/bash
juju bootstrap --to node01 maas-cloud maas-cloud-controller
sleep 30
juju add-model --config default-series=focal openstack
