#!/bin/zsh

# Get folder that this script is in
SCRIPT_DIR=${0:a:h}

# Get functions and settings
. "${SCRIPT_DIR}/functions.zsh"
. "${SCRIPT_DIR}/settings.zsh"

# store the current hostname from cloudflare API
CURRENT_HOST=$(cloudflare_dns_query $ZONE_ID $DNS_ID $TOKEN | jq -r '.result.content')

# check if connection is refused
curl -ISs "https://${SERVER_A}" > /dev/null
SERVER_A_CONNECT=$?

if [[ $SERVER_A_CONNECT == 0 ]] {
    # the connection to server A was successful
    if [[ $CURRENT_HOST == $SERVER_A ]] {
        # A is up and is the current host (so we are good)
        exit 0
    } elif [[ $CURRENT_HOST == $SERVER_B ]] {
        # A is up, but the current CNAME is B
        date_time_echo "${SERVER_A} is back up! Rotating DNS to ${SERVER_A}."
        cloudflare_dns_update "$DOMAIN_MAIN" "$SERVER_A" "$ZONE_ID" "$DNS_ID" "$TOKEN"
    } else {
        # CNAME is weird; do nothing
        date_time_echo "The connection to the server was successful, but the current CNAME is ${CURRENT_HOST}. Expected ${SERVER_A} or ${SERVER_B}."
        exit 1
    }
} elif [[ $SERVER_A_CONNECT == 7 ]] {
    # the connection to A was refused (code 7)
    if [[ $CURRENT_HOST == $SERVER_A ]] {
        # the current CNAME is A and it is down
        date_time_echo "${SERVER_A} went down!"
        curl -ISs "https://${SERVER_B}" > /dev/null && {
            date_time_echo "${SERVER_B} is up. Rotating DNS to ${SERVER_B}."
            cloudflare_dns_update "$DOMAIN_MAIN" "$SERVER_B" "$ZONE_ID" "$DNS_ID" "$TOKEN"
        }
    } elif [[ $CURRENT_HOST == $SERVER_B ]] {
        # A is down, and the CNAME is B (presumably because we changed it)
        exit 0
    } else {
        # CNAME is weird; do nothing
        date_time_echo "The connection to the server failed, but the current CNAME is ${CURRENT_HOST}. Expected ${SERVER_A} or ${SERVER_B}."
        exit 1
    }
} else {
    # curl failed in an unexpected way; do nothing
    date_time_echo "Connection failed with error $SERVER_A_CONNECT. Expected error 7 or success."
    exit 1
}

