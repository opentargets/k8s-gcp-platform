#!/bin/bash

# Check for the correct number of arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <create|destroy>"
    exit 1
fi

ACTION=$1

# Location of the DNS services
export GKE_PROJECT_ID="open-targets-eu-dev"
export DNS_PROJECT_ID="${GKE_PROJECT_ID}"
export DNS_MANAGED_ZONE="opentargets-xyz"

# ExternalDNS GCP Service Account definition
export DNS_SA_NAME="external-dns-sa"
export DNS_SA_EMAIL="$DNS_SA_NAME@${GKE_PROJECT_ID}.iam.gserviceaccount.com"

# KSA definitions
export EXTERNALDNS_NS="external-dns"

case $ACTION in
    create)
        # Setup ExternalDNS GCP Service Account
        echo "[CREATE]Create ExternalDNS GCP Service Account, '$DNS_SA_NAME'"
        gcloud iam service-accounts create $DNS_SA_NAME --display-name "$DNS_SA_NAME"
        echo "[CREATE]Add DNS Admin role to ExternalDNS GCP Service Account, '$DNS_SA_EMAIL'"
        gcloud projects add-iam-policy-binding $DNS_PROJECT_ID \
            --member serviceAccount:$DNS_SA_EMAIL \
            --role roles/dns.admin \
            --condition="expression=true,title=always-true,description='This role is always granted'"
        echo "[CREATE]Link KSA to GSA"
        gcloud iam service-accounts add-iam-policy-binding $DNS_SA_EMAIL \
            --role "roles/iam.workloadIdentityUser" \
            --member "serviceAccount:$GKE_PROJECT_ID.svc.id.goog[${EXTERNALDNS_NS:-"default"}/external-dns]"
        ;;
    destroy)
        # Remove ExternalDNS GCP Service Account bindings and account itself
        echo "[DESTROY]Unlink KSA from GSA"
        gcloud iam service-accounts remove-iam-policy-binding $DNS_SA_EMAIL \
            --role "roles/iam.workloadIdentityUser" \
            --member "serviceAccount:$GKE_PROJECT_ID.svc.id.goog[${EXTERNALDNS_NS:-"default"}/external-dns]" --quiet
        echo "[DESTROY]Remove DNS Admin role from ExternalDNS GCP Service Account, '$DNS_SA_EMAIL'"
        gcloud projects remove-iam-policy-binding $DNS_PROJECT_ID \
            --member serviceAccount:$DNS_SA_EMAIL --role "roles/dns.admin" --all --quiet
        echo "[DESTROY]Delete ExternalDNS GCP Service Account, '$DNS_SA_NAME'"
        gcloud iam service-accounts delete $DNS_SA_EMAIL --quiet
        ;;
    *)
        echo "Invalid action: $ACTION"
        echo "Usage: $0 <create|destroy>"
        exit 1
        ;;
esac
