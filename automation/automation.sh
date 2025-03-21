#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!" 
   exit 1
fi

# Ask for target IP or domain
read -p "Enter target IP or domain: " TARGET
read -p "Enter directory name for results: " REPORT_DIR

# Create a directory for storing results
mkdir -p "automation/$REPORT_DIR" && cd "automation/$REPORT_DIR"

# Timestamp for report
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Start the scan and save results
echo "[*] Running full reconnaissance and vulnerability scan..."

# Step 1: Full Port Scan with Nmap
echo "[*] Running Nmap scan..."
sudo nmap -p- -sS -sV -O --script=vuln,ssl-enum-ciphers -T4 "$TARGET" -oN nmap_scan.txt

# Step 2: Web Vulnerability Scan with Nikto
echo "[*] Running Nikto scan..."
nikto -h "https://$TARGET" -Tuning x -ssl -C all -o nikto_scan.txt

# Step 3: CVE Scanning with Nuclei
echo "[*] Running Nuclei scan..."
nuclei -u "https://$TARGET" -o nuclei_scan.txt

# Step 4: Extract Critical Information
echo "[*] Extracting critical findings..."

echo "### Penetration Testing Report" > report.md
echo "**Target:** $TARGET" >> report.md
echo "**Date:** $(date)" >> report.md
echo "" >> report.md

echo "## 🔍 Nmap Scan Results" >> report.md
grep "open" nmap_scan.txt >> report.md
echo "" >> report.md

echo "## 🌐 Web Vulnerability Results (Nikto)" >> report.md
grep "OSVDB" nikto_scan.txt >> report.md
echo "" >> report.md

echo "## ⚠️ CVE Findings (Nuclei)" >> report.md
cat nuclei_scan.txt >> report.md
echo "" >> report.md

# Step 5: Convert Markdown Report to PDF (Requires `pandoc`)
echo "[*] Generating PDF report..."
pandoc report.md -o report_$TIMESTAMP.pdf

echo "[*] Automation complete! Reports saved in automation/$REPORT_DIR"
ls -lah
