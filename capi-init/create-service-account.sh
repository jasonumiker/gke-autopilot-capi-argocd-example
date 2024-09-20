#!/bin/zsh
export GCP_PROJECT=project-435400
export SERVICE_ACCOUNT_USER=capi-sa
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/capi-sa.json"

gcloud iam service-accounts create "$SERVICE_ACCOUNT_USER" --project=$GCP_PROJECT
gcloud projects add-iam-policy-binding $GCP_PROJECT --member="serviceAccount:$SERVICE_ACCOUNT_USER@$GCP_PROJECT.iam.gserviceaccount.com" --role=roles/editor
gcloud projects add-iam-policy-binding $GCP_PROJECT --member="serviceAccount:$SERVICE_ACCOUNT_USER@$GCP_PROJECT.iam.gserviceaccount.com" --role=roles/iam.serviceAccountTokenCreator
gcloud projects add-iam-policy-binding $GCP_PROJECT --member="serviceAccount:$SERVICE_ACCOUNT_USER@$GCP_PROJECT.iam.gserviceaccount.com" --role=roles/container.admin
gcloud iam service-accounts keys create $GOOGLE_APPLICATION_CREDENTIALS --iam-account="$SERVICE_ACCOUNT_USER@$GCP_PROJECT.iam.gserviceaccount.com"