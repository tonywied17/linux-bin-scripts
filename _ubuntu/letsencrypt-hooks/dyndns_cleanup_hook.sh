#!/bin/bash

# Dynadot API credentials
DYNADOT_API_KEY=""
DOMAIN="${CERTBOT_DOMAIN}"
SUBDOMAIN="_acme-challenge"

# Set the DNS record using the set_dns2 command with add_dns_to_current_setting
response=$(curl -s "https://api.dynadot.com/api3.xml?key=${DYNADOT_API_KEY}&command=set_default_dns2&domain=${DOMAIN}&main_record_type0=txt&main_record0=${SUBDOMAIN}&main_recordx0=&ttl=60&add_dns_to_current_setting=1")

# Check if the response indicates success
success_code=$(echo "$response" | grep -oP '(?<=<SuccessCode>).*?(?=</SuccessCode>)')

if [[ "$success_code" -eq 0 ]]; then
    echo "DNS challenge cleaned up successfully."
else
    echo "Error: Failed to delete DNS record for ${DOMAIN}."
    echo "Response: $response"
    exit 1
fi
