#!/bin/bash
juju bootstrap --to node01.maas --config default-series=focal maas-cloud maas-cloud-controller
sleep 30
juju add-model --config default-series=focal kubernetes
