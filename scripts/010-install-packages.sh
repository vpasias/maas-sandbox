#!/usr/bin/env bash

set -x

echo "Installing packages"
snap install jq
sudo snap install maas-test-db
sudo snap install maas --channel=2.9/stable
