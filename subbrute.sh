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
