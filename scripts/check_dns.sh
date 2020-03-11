#!/usr/bin/env bash

# Simple script to check provided DNS records

set -e

ValidHostnameRegex="^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}\.?$"
ValidParameter="^[\.a-zA-Z0-9-]+:[\.a-zA-Z0-9-]+$"
DNS_Zone=""
Timeout=$((SECONDS+300))

if [[ $# == 0 ]]; then
	echo -e "ERROR:\tParameters are not specified!"
    echo -e "\tUsage example: $0 example.com test:127.0.0.1 almost.not-test:127.0.0.2 not-test:test.example.com."
	exit 1
fi

if [[ $# -ge 1 ]]; then
    if [[ $1 =~ $ValidHostnameRegex ]]; then
        DNS_Zone=$1
        shift
    else
        echo -e "ERROR:\tFist parameter should be valid domain name"
        exit 1
    fi

    if [[ $# -ge 1 ]]; then
        Parameters=$*

        for Parameter in $Parameters; do
            if [[ $Parameter =~ $ValidParameter ]]; then
                DNS_Prefix=$(echo "$Parameter" | cut -d':' -f1)
                DNS_Value=$(echo "$Parameter" | cut -d':' -f2)
                if [[ "$DNS_Value" == "null" ]]; then continue; fi
                until [[ $(dig +short "$DNS_Prefix.$DNS_Zone" | head -n1 | tr -d '\n') == "${DNS_Value,,}" || $SECONDS -ge $Timeout ]]; do
                    sleep 5
                    echo "Check that \"$DNS_Prefix.$DNS_Zone\" resolves as \"$DNS_Value\"..."
                done
            else
                echo -e "ERROR:\tParameters must be in '<host.prefix>:<value>' format"
                exit 1
            fi
        done
    else
        echo -e "ERROR:\tNo parameters for checking are provided"
        exit 1
    fi
fi
