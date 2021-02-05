#!/bin/bash
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --config min-cluster-size=3 cs:rabbitmq-server rabbitmq-server
