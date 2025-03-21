#!/bin/bash

# Ask for the target IP address
read -p "Enter the target IP address: " TARGET_IP

# Ask for the directory name to store scan results
read -p "Enter the directory name to save results: " SCAN_DIR

# Create the specified directory and navigate into it
mkdir -p "$SCAN_DIR" && cd "$SCAN_DIR"

echo "Starting Full Port Scan..."
sudo nmap -p- -sS -sV -O -Pn --open --script=vuln,ssl-enum-ciphers -T4 "$TARGET_IP" -oN full_scan.txt

echo "Starting Web Enumeration..."
sudo nmap --script=http-enum,http-title,http-methods,http-headers,http-trace,ssl-cert -p 443 "$TARGET_IP" -oN http_enum.txt

echo "Starting Nikto Scan..."
nikto -h "https://$TARGET_IP" -Tuning x -ssl -C all -o nikto_results.txt

echo "All scans completed. Results saved in '$SCAN_DIR' directory."
