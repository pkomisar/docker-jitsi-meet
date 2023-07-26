#!/bin/bash

if [ -z "$WHISK_AUTH" ] || [ -z "$GET_MY_IP_URL" ] || [ -z "$UPDATE_DOMAIN" ] || [ -z "$UPDATE_RECORD_ID" ]; then
    echo "One or more of the required environment variables (WHISK_AUTH, GET_MY_IP_URL, UPDATE_DOMAIN, UPDATE_RECORD_ID) are not set."
    exit 1
fi

echo "Getting my IP from own function..."
ip_addr=$(curl -s -H "X-Require-Whisk-Auth: $WHISK_AUTH" "$GET_MY_IP_URL" | tr -d '\n')

echo "Got IP $ip_addr"

api_url="https://api.digitalocean.com/v2/domains/$UPDATE_DOMAIN/records/$UPDATE_RECORD_ID"
auth_header="Bearer $DO_API_KEY"

response=$(curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: $auth_header" -d "{\"type\":\"A\", \"data\":\"$ip_addr\"}" "$api_url")

record_data=$(echo $response | jq -r '.domain_record.data')
record_name=$(echo $response | jq -r '.domain_record.name')

if [ "$record_data" = "$ip_addr" ]; then
    echo "Success! $record_name.$UPDATE_DOMAIN is set to $ip_addr"
    exit 0
else
    echo "Got $record_data for $record_name"
    exit 1
fi