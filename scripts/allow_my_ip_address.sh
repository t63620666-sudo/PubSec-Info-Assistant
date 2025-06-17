#!/bin/bash

echo "Getting the public IP address of the machine..."
ip_address=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}')

if [ -z "$ip_address" ]; then
  echo "Failed to retrieve the public IP address."
  exit 1
fi

echo "Adding the IP address $ip_address to the allowed IPs list..."

if azd env set AZURE_ALLOWED_IPS "$ip_address"; then
    echo "Successfully added the IP address $ip_address to the allowed IPs list."
else
    echo "Failed to add the IP address $ip_address to the allowed IPs list."
    exit 1
fi