#!/bin/zsh
kubectl apply -f metrics-server.yaml
export GCP_B64ENCODED_CREDENTIALS=$( cat ~/capi-sa.json | base64 | tr -d '\n' )
export EXP_CAPG_GKE=true
clusterctl init --infrastructure gcp --addon helm
