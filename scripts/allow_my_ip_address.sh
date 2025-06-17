#!/bin/bash

echo "Getting the public IP address of the machine..."
ip_address=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}')

if [ -z "$ip_address" ]; then
  echo "Failed to retrieve the public IP address."
  exit 1
fi

echo "Adding the IP address $ip_address to the allowed IPs list..."

allowed_ips=$(azd env get-value AZURE_ALLOWED_IPS)

if [ -z "$allowed_ips" ]; then
  allowed_ips="$ip_address"
else
  # Check if ip_address is already in the comma-separated list (any position)
  IFS=',' read -ra ip_array <<< "$allowed_ips"
  found=0
  for ip in "${ip_array[@]}"; do
    if [[ "$ip" == "$ip_address" ]]; then
      found=1
      break
    fi
  done
  if [[ $found -eq 0 ]]; then
    allowed_ips="${allowed_ips},$ip_address"
  fi
fi

if azd env set AZURE_ALLOWED_IPS "$allowed_ips"; then
    echo "Successfully added the IP address $ip_address to the allowed IPs list."
else
    echo "Failed to add the IP address $ip_address to the allowed IPs list."
    exit 1
fi