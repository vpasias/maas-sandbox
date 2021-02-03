# normal
juju destroy-controller -y --destroy-all-models --destroy-storage maas-controller

# Force Kill
# last resort if your juju bootsrap controller inaccessible and something to removal fails.
# juju kill-controller -y maas-controller
