#!/bin/bash
#juju add-k8s maas-cloud --controller $(juju switch | cut -d: -f1)
#
#juju add-model metallb-system maas-cloud
#
juju deploy cs:~containers/metallb
#
juju config metallb-controller iprange="192.168.10.240-192.168.10.241"
