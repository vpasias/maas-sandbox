#!/bin/bash
# normal
juju destroy-controller -y --destroy-all-models --destroy-storage maas-cloud-controller

# Force Kill
# last resort if your juju bootsrap controller inaccessible and something to removal fails.
# juju kill-controller -y maas-cloud-controller
