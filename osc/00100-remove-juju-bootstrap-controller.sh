#!/bin/bash
# normal
juju destroy-controller -y --destroy-all-models --destroy-storage maas-cloud-controller
#juju destroy-model -y --destroy-storage openstack

# Force Kill
# last resort if your juju bootsrap controller inaccessible and something to removal fails.
# juju kill-controller -y maas-controller
