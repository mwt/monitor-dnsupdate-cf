date_time_echo() {
    local DATE_BRACKET=$(date +"[%D %T]")
    echo "$DATE_BRACKET" "$@"
}

cloudflare_dns_query() {
    local ZONE_ID=$1
    local DNS_ID=$2
    local TOKEN=$3

    curl -sX GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_ID" \
         -H "Authorization: Bearer $TOKEN" \
         -H "Content-Type: application/json" \
}

cloudflare_dns_update() {
    local NAME=$1
    local CONTENT=$2

    local ZONE_ID=$3
    local DNS_ID=$4
    local TOKEN=$5

    local TYPE=${6:-'CNAME'}
    local PROXIED=${7:-'false'}
    local TTL=${8:-'1'}

    curl -sX PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_ID" \
         -H "Authorization: Bearer $TOKEN" \
         -H "Content-Type: application/json" \
         --data '{"type":"'"$TYPE"'","name":"'"$NAME"'","content":"'"$CONTENT"'","proxied":'"$PROXIED"',"ttl":'"$TTL"'}'
}
