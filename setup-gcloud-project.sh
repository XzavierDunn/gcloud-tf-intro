#!/bin/bash
set -e

usage() {
    echo "Usage: <PROJECT-ID> [-b Billing account ID] [-n NAME] [-l LABEL] [-v VERBOSE] [-h HELP]"
    echo "  -b, --billing   Billing Account ID"
    echo "  -n, --name      Project Name, ID will be used if not provided"
    echo "  -l, --labels     Project Labels"
    echo "  -v, --verbose   Verbose output"
    echo "  -h, --help      Display this help message."
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

# Default values
id=$1
name=$1
labels=""
billing_account_id=""
verbose=false

# Check Flags
shift
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h | --help) usage; exit 2; ;;
        -n | --name) 
            name="$2"
            shift 2
            ;;
        -l | --labels) 
            labels="$2"
            shift 2
            ;;
        -v | --verbose) 
            verbose=true;
            shift;
            ;;
        -b | --billing) 
            billing_account_id="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
  esac
done

echo -e "Creating project with \n ID: $id\n Name: $name\n Labels: $labels\n Billing Account ID: $billing_account_id"
gcloud projects create $id --name $name --labels $labels

if [ billing_account_id != "" ]; then
    echo -e "\nAttempting to enable billing for project $id"
    gcloud beta billing projects link $id --billing-account $billing_account_id

    echo -e "\nAttempting to enable services for project $id"
    gcloud services enable compute.googleapis.com --project $id

    echo -e "\nNow deploying infrastructure"
    terraform apply -auto-approve -var project_id=$id
fi

echo -e "\nProject setup complete\nDashboard: https://console.cloud.google.com/home/dashboard?project=$id"
