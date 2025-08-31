#!/bin/bash

# ANSI color codes for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Banner with improved ASCII art
print_banner() {
    echo -e "${PURPLE}"
    cat << "EOF"
 ██╗  ██╗ ██████╗ ███████╗████████╗    ██╗  ██╗███████╗ █████╗ ██████╗ ██████╗ ███████╗██████╗ 
 ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝    ██║  ██║██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
 ███████║██║   ██║███████╗   ██║       ███████║█████╗  ███████║██║  ██║██████╔╝█████╗  ██║  ██║
 ██╔══██║██║   ██║╚════██║   ██║       ██╔══██║██╔══╝  ██╔══██║██║  ██║██╔══██╗██╔══╝  ██║  ██║
 ██║  ██║╚██████╔╝███████║   ██║       ██║  ██║███████╗██║  ██║██████╔╝██║  ██║███████╗██████╔╝
 ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝       ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝ 
EOF
    echo -e "${NC}"
    echo -e "${CYAN}        Host Header Injection Scanner${NC}"
    echo -e "${RED}        build by Anku (https://github.com/ankuji001)${NC}"
    echo -e "${YELLOW}        Follow on instagram : https://www.instagram.com/ig.anku/${NC}"
    echo
}

# Function to display help
show_help() {
    print_banner
    echo -e "${GREEN}Usage:${NC} $0 [OPTIONS]"
    echo
    echo -e "${GREEN}Options:${NC}"
    echo -e "  -u, --url <URL>         Target URL to scan (required)"
    echo -e "  -p, --payload <HOST>    Custom malicious host (default: evil.com)"
    echo -e "  -h, --help              Show this help menu"
    echo -e "  -v, --version           Show version information"
    echo
    echo -e "${GREEN}Examples:${NC}"
    echo -e "  $0 -u https://example.com"
    echo -e "  $0 --url https://target.com --payload malicious.site"
    echo
    echo -e "${GREEN}Required tools:${NC} curl, grep, sed, bash"
}

# Function to check dependencies
check_dependencies() {
    local dependencies=("curl" "grep" "sed")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${RED}[ERROR]${NC} $dep is not installed. Please install it to continue."
            exit 1
        fi
    done
}

# Function to generate payloads
generate_payloads() {
    local base_payload="$1"
    local payloads=()
    
    payloads=(
        "$base_payload"
        "${base_payload}:443"
        "attacker.${base_payload}"
        "${base_payload}.attackersite.com"
        "localhost"
        "127.0.0.1"
        "0.0.0.0"
        "2130706433" # 127.0.0.1 in decimal
        "localhost:80"
        "127.0.0.1:8080"
        "localhost:443"
        "example.com"
        "subdomain.${base_payload}"
        "www.${base_payload}"
        "api.${base_payload}"
        "test.${base_payload}"
        "dev.${base_payload}"
        "staging.${base_payload}"
        "prod.${base_payload}"
        "admin.${base_payload}"
        "login.${base_payload}"
    )
    
    printf '%s\n' "${payloads[@]}"
}

# Function to test a single header
test_header() {
    local url="$1"
    local header_name="$2"
    local payload="$3"
    
    local response
    response=$(curl -s -I -H "${header_name}: ${payload}" "$url" 2>&1)
    
    if echo "$response" | grep -q "HTTP/"; then
        local status_code=$(echo "$response" | grep "HTTP/" | awk '{print $2}')
        echo "$status_code"
    else
        echo "ERROR"
    fi
}

# Function to display progress bar
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local remaining=$((width - completed))
    
    printf "\r["
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "] %3d%%" "$percentage"
}

# Main scanning function
run_scan() {
    local target_url="$1"
    local malicious_host="$2"
    
    print_banner
    
    # Validate URL format
    if [[ ! "$target_url" =~ ^https?:// ]]; then
        echo -e "${RED}[ERROR]${NC} URL must start with http:// or https://"
        exit 1
    fi
    
    echo -e "${CYAN}[*]${NC} Target URL: ${WHITE}$target_url${NC}"
    echo -e "${CYAN}[*]${NC} Payload base: ${WHITE}$malicious_host${NC}"
    echo -e "${CYAN}[*]${NC} Checking dependencies..."
    check_dependencies
    echo
    
    # Headers to test
    local headers=(
        "Host"
        "X-Forwarded-Host"
        "X-Host"
        "X-Original-Host"
        "Forwarded"
        "X-Forwarded-Server"
        "X-HTTP-Host-Override"
        "Origin"
        "Referer"
    )
    
    # Generate payloads
    echo -e "${CYAN}[*]${NC} Generating payload variants..."
    local payloads=()
    mapfile -t payloads < <(generate_payloads "$malicious_host")
    echo -e "${GREEN}[+]${NC} Generated ${#payloads[@]} payload variants"
    echo
    
    local total_tests=$(( ${#headers[@]} * ${#payloads[@]} ))
    local current_test=0
    local results=()
    
    echo -e "${CYAN}[*]${NC} Starting scan..."
    echo
    
    # Test all header and payload combinations
    for header in "${headers[@]}"; do
        for payload in "${payloads[@]}"; do
            current_test=$((current_test + 1))
            progress_bar "$current_test" "$total_tests"
            
            local status_code
            status_code=$(test_header "$target_url" "$header" "$payload")
            
            # Store results
            if [[ "$status_code" != "ERROR" ]]; then
                results+=("$header|$payload|$status_code")
            fi
            
            # Small delay to avoid overwhelming the server
            sleep 0.1
        done
    done
    
    echo -e "\n\n${GREEN}[+]${NC} Scan completed!"
    echo
    
    # Display results
    if [ ${#results[@]} -eq 0 ]; then
        echo -e "${YELLOW}[!]${NC} No interesting responses detected."
    else
        echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
        echo -e "${WHITE}                    SCAN RESULTS${NC}"
        echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
        echo -e "${WHITE}HEADER               PAYLOAD                 STATUS  RISK${NC}"
        echo -e "${CYAN}──────────────────────────────────────────────────────────────${NC}"
        
        for result in "${results[@]}"; do
            IFS='|' read -r header payload status <<< "$result"
            
            # Determine risk level based on status code
            local risk="LOW"
            local color="$YELLOW"
            
            if [[ "$status" =~ ^[45] ]]; then
                risk="MEDIUM"
                color="$YELLOW"
            fi
            
            if [[ "$status" =~ ^[23] ]] && [[ "$status" != "200" ]]; then
                risk="HIGH"
                color="$RED"
            fi
            
            # Trim long strings for display
            local header_display="${header:0:18}"
            local payload_display="${payload:0:22}"
            
            printf "${WHITE}%-20s %-23s ${color}%-7s %-5s${NC}\n" \
                   "$header_display" "$payload_display" "$status" "$risk"
        done
        
        echo -e "${CYAN}──────────────────────────────────────────────────────────────${NC}"
        echo
        echo -e "${GREEN}[+]${NC} Found ${#results[@]} interesting responses!"
    fi
    
    echo
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Thank you for using Host Header Injection Scanner!${NC}"
    echo -e "${CYAN}Follow for more tools:${NC}"
    echo -e "${WHITE}GitHub:   https://github.com/ankuji001${NC}"
    echo -e "${WHITE}Instagram: https://www.instagram.com/ig.anku/${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
}

# Parse command line arguments
parse_arguments() {
    local url=""
    local payload="evil.com"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--url)
                url="$2"
                shift 2
                ;;
            -p|--payload)
                payload="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "Host Header Injection Scanner v1.0"
                echo "Created by Anku"
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR]${NC} Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    if [ -z "$url" ]; then
        echo -e "${RED}[ERROR]${NC} URL is required. Use -u or --url option."
        show_help
        exit 1
    fi
    
    run_scan "$url" "$payload"
}

# Main execution
if [[ $# -eq 0 ]]; then
    show_help
else
    parse_arguments "$@"
fi
