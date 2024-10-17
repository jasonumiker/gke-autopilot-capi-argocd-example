#!/bin/bash
export PROJECT_NUMBER=700579028093
export PROJECT_ID=project-435400
export NAMESPACE_NAME=external-dns
export SERVICE_ACCOUNT_NAME=external-dns

gcloud projects add-iam-policy-binding projects/$PROJECT_ID \
    --role=roles/dns.admin \
    --member=principal://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$PROJECT_ID.svc.id.goog/subject/ns/$NAMESPACE_NAME/sa/$SERVICE_ACOUNT_NAME \
    --condition=None