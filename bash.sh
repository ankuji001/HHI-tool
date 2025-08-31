#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
echo -e "${YELLOW}"
echo "   _    _ _    _    _   _ _   _ "
echo "  | |  | | |  | |  | | | | | | |"
echo "  | |__| | |__| |__| |_| | |_| |"
echo "  |  __  |  __  |__   _| |__   _|"
echo "  | |  | | |  | |  | | | |  | |  "
echo "  |_|  |_|_|  |_|  |_| |_|  |_|  "
echo -e "${NC}"
echo "Host Header Injection Tester"
echo "----------------------------"

# Get target URL
read -p "Enter target URL (e.g., http://example.com): " url

# Validate URL format
if [[ ! $url =~ ^http(s)?:// ]]; then
    echo -e "${RED}[!] Invalid URL format. Include http:// or https://${NC}"
    exit 1
fi

# Get payload
echo -e "${YELLOW}[i] Example payload: evil.com${NC}"
read -p "Enter payload: " payload

# Headers to test
headers=(
    "Host: $payload"
    "X-Forwarded-Host: $payload"
    "X-Host: $payload"
    "X-Original-Host: $payload"
    "Forwarded: for=127.0.0.1;host=$payload;proto=http"
    "X-Forwarded-Server: $payload"
)

# Test each header
for header in "${headers[@]}"; do
    echo -e "\n${YELLOW}Testing ${header}...${NC}"
    
    # Extract header name for reporting
    header_name=$(echo "$header" | cut -d: -f1)
    
    # Send request
    response=$(curl -s -k -H "$header" -I "$url" 2>&1)
    response_body=$(curl -s -k -H "$header" -L "$url" 2>&1)

    # Check for reflection
    if echo "$response$response_body" | grep -iq "$payload"; then
        echo -e "${GREEN}[+] VULNERABLE - ${header_name} reflection found${NC}"
    else
        echo -e "${RED}[-] Not vulnerable - ${header_name}${NC}"
    fi

    # Check for redirects
    if echo "$response" | grep -i "location.*$payload"; then
        echo -e "${GREEN}[+] OPEN REDIRECT possible with ${header_name}${NC}"
    fi
done

echo -e "\n${YELLOW}[i] Scan completed. Manual verification recommended.${NC}"