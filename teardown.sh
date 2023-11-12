#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: <PROJECT-ID>"
    exit 1
fi

echo -e "Tearing down project $1\n"
echo "Running terraform destroy..."
terraform destroy -auto-approve -var project_id=$1

echo -e "\nRunning gcloud projects delete..."
gcloud projects delete $1 -q

echo "Success"
