#!/usr/bin/env bash

set -o errexit
set -o xtrace

cp variables.tf 01-vpc/
cp variables.tf 02-single-instance/
cp variables.tf 03-provision-instance/
cp variables.tf 04-load-balancer/
cp variables.tf 05-dns/
