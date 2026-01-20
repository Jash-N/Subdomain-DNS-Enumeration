# Subdomain-DNS-Enumeration (Subdomain takeover)
This project is a Bash-based reconnaissance script created to assist in subdomain enumeration during web application penetration testing revealing potential subdomain takeover.

The script:
- Enumerates subdomains using a wordlist
- Resolves DNS records for each subdomain
- Identifies whether a subdomain is:
    - Directly hosted (A / AAAA records), or
    - Pointing to a third-party service (CNAME record)

This information is useful during the initial recon phase to identify potentially interesting or misconfigured subdomains.

## The Script
```bash
#!/bin/bash

domain="$1"
wordlist="best-dns-wordlist.txt"

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

echo "[*] Enumerating subdomains for: $domain"
echo

while read -r sub; do
    fqdn="$sub.$domain"

    dns_output=$(dig "$fqdn" +noall +answer)

    [ -z "$dns_output" ] && continue

    cname=$(echo "$dns_output" | awk '$4 == "CNAME" {print $5}')

    if [ -n "$cname" ]; then
        echo "$fqdn  CNAME  $cname"
    else
        ip=$(echo "$dns_output" | awk '$4 == "A" || $4 == "AAAA" {print $5}')
        [ -n "$ip" ] && echo "$fqdn  A  $ip"
    fi

done < "$wordlist"
```
## How to use the Script
1. Ensure you have a subdomain wordlist in the same directory
(example: best-dns-wordlist.txt)
2. Give execute permission:
```bash
chmod +x subbrute.sh
```
3. Run the script with a target domain:
```bash
./subbrute.sh example.com
```

## High Level Script Flow
1. Takes a target domain as input
2. Reads subdomain names from a wordlist
3. Appends each subdomain to the target domain
4. Queries DNS records using ```dig```
5. Filters out non-resolving subdomains
6. Displays:
   - CNAME records (third-party hosting)
   - A / AAAA records (direct IP hosting)

## Key Features & Tools Used
```dig``` (DNS Lookup)

```dig``` is a DNS lookup utility used to query DNS servers.
In this script, it is used to:
  - Check whether a subdomain exists
  -  Retrieve DNS record types associated with it

The option ```+noall +answer``` ensures that only the relevant DNS answer section is displayed.

## DNS Record Types
- A Record</br>
    Maps a domain or subdomain to an IPv4 address</br>
    → Usually indicates direct hosting

- AAAA Record</br>
    Maps a domain or subdomain to an IPv6 address</br>
    → Also indicates direct hosting

- CNAME Record</br>
    Points a domain or subdomain to another domain name</br>
    → Often used for third-party services (e.g., GitHub Pages, AWS)

## Disclaimer
This script is intended only for educational purposes and should be used only on domains you own or have explicit permission to test.
