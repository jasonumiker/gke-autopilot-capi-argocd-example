#!/bin/zsh
kubectl create secret \
generic gcp-secret \
-n crossplane-system \
--from-file=creds=/home/jumiker/capi-sa.json
