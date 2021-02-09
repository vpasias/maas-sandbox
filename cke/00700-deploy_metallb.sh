#!/bin/bash
juju add-k8s k8s-cloud --controller $(juju switch | cut -d: -f1)
#
juju add-model metallb-system k8s-cloud
#
juju deploy cs:~containers/metallb
#
juju config metallb-controller iprange="192.168.1.240-192.168.1.241"
