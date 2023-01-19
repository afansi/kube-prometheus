#!/usr/bin/env bash

# refer to this page for how to setup the install: 
###  https://github.com/prometheus-operator/kube-prometheus/blob/main/docs/customizing.md
### The tool gojsontoyaml could be found here: https://github.com/brancz/gojsontoyaml
### The tool Go could be installed following instruction from here: https://go.dev/doc/install
### The tool jb could be installed follwing the instruction from here: https://github.com/jsonnet-bundler/jsonnet-bundler#install

# This script uses arg $1 (name of *.jsonnet file to use) to generate the manifests/*.yaml files.

FILE=ingress-talky-kube-prometheus-auth
if [ -f "$FILE" ]; then
    echo "$FILE exists and will be used to set up ingress authentication."
else 
    echo "$FILE does not exist. Please create it using 'htpasswd -c ingress-talky-kube-prometheus-auth <username>'"
    exit 1
fi


set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

# Make sure to use project tooling
PATH="$(pwd)/tmp/bin:${PATH}"

# Make sure to start with a clean 'manifests' dir
rm -rf manifests
mkdir -p manifests/setup

## Calling gojsontoyaml is optional, but we would like to generate yaml, not json
jsonnet -J vendor -m manifests "${1-example.jsonnet}" | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml' -- {}


# Make sure to remove json files
find manifests -type f ! -name '*.yaml' -delete
rm -f kustomization

