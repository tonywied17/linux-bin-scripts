#!/bin/bash
sudo resolvectl flush-caches
DYNADOT_API_KEY=""
DOMAIN="${CERTBOT_DOMAIN}"

echo "CERTBOT_DOMAIN: ${CERTBOT_DOMAIN}"
echo "CERTBOT_VALIDATION: ${CERTBOT_VALIDATION}"

# Add DNS record using CERTBOT_VALIDATION (the validation string for DNS-01)
if [ -n "${CERTBOT_VALIDATION}" ]; then
    echo "Adding DNS TXT record for _acme-challenge.${DOMAIN} with validation: ${CERTBOT_VALIDATION}"

    response=$(curl -s "https://api.dynadot.com/api3.xml?key=${DYNADOT_API_KEY}&command=set_dns2&domain=${CERTBOT_DOMAIN}&subdomain0=_acme-challenge&sub_record_type0=txt&sub_record0=${CERTBOT_VALIDATION}&add_dns_to_current_setting=1")

    success_code=$(echo "$response" | grep -oP '(?<=<SuccessCode>).*?(?=</SuccessCode>)')

    if [[ "$success_code" -eq 0 ]]; then
        echo "DNS challenge added successfully."

        sleep 360
        sudo resolvectl flush-caches
        sudo resolvectl statistics
        sleep 60
        sudo resolvectl flush-caches
        dig _acme-challenge.molex.cloud TXT
    else
        echo "Error: Failed to add DNS record for ${DOMAIN}."
        echo "Response: $response"
        exit 1
    fi
else
    echo "Error: CERTBOT_VALIDATION is empty for domain ${CERTBOT_DOMAIN}. Skipping DNS challenge."
    exit 1
fi