# monitor-dnsupdate-cf

A Zsh script to monitor a site with two origin servers and rotate DNS when the primary one goes down. It requires a `settings.zsh` file with the following contents:

```sh
TOKEN="{{ Cloudflare Token }}"
ZONE_ID="{{ Cloudflare Zone ID }}"
DNS_ID="{{ Cloudflare DNS ID }}"

DOMAIN_MAIN="domain.tld"
SERVER_A="a.domain.tld"
SERVER_B="b.domain.tld"
```

Where the first three are for the Cloudflare API (corresponding to `$DOMAIN_MAIN`) and the last three are domains. The first domain, `$DOMAIN_MAIN` is the client facing domain. The other two, `$SERVER_A` and `$SERVER_B` should point to your main and backup server respectively. When server A goes down, the script sets the CNAME record for the main domain to `$SERVER_B`. When server A is back up, the script sets the CNAME record for the main domain back to `$SERVER_A`.

Only `$DOMAIN_MAIN` needs to be managed at Cloudflare. The other two hosts do not need to be on Cloudflare. They also do not need to be subdomains of the main domain.

## Dependencies

This package requires `zsh`, `curl`, and `jq` to be installed.
