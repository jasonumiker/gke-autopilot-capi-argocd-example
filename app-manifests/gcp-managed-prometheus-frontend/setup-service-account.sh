#!/bin/zsh
gcloud config set project project-435400 
gcloud iam service-accounts create gmp-sa 
gcloud iam service-accounts add-iam-policy-binding \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:project-435400.svc.id.goog[default/default]" \
  gmp-sa@project-435400.iam.gserviceaccount.com 
kubectl annotate serviceaccount \
  --namespace default \
  default \
  iam.gke.io/gcp-service-account=gmp-sa@project-435400.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding project-435400 \
  --member=serviceAccount:gmp-sa@project-435400.iam.gserviceaccount.com \
  --role=roles/monitoring.viewer
