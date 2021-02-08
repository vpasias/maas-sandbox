#!/bin/bash
wget https://raw.githubusercontent.com/charmed-kubernetes/kubernetes-docs/master/assets/graylog-vhost.tmpl
juju config apache2 vhost_http_template="$(base64 ~/home/vagrant/maas-sandbox/cke/graylog-vhost.tmpl)"
#
juju status --format yaml apache2/0 | grep public-address
# public-address: <apache2-ip>
juju run-action --wait graylog/0 show-admin-password
# admin-password: <graylog-password>
