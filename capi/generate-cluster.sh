#!/bin/zsh
export GCP_NETWORK_NAME=default
export GCP_PROJECT=project-435400
export GCP_REGION=australia-southeast1
clusterctl generate cluster capi-gke --flavor gke --worker-machine-count=1 > capi-gke.yaml