
wget https://raw.githubusercontent.com/charmed-kubernetes/kubernetes-docs/master/assets/graylog-vhost.tmpl
juju config apache2 vhost_http_template="$(base64 ~/home/vagrant/maas-sandbox/cke/graylog-vhost.tmpl)"
