#!/bin/bash
url=$1
if [ ! -d "$url" ];then
  mkdir $url
fi
if [ ! -d "$url/nmap-scans" ];then
  mkdir $url/nmap-scans
fi
if [ ! -d "$url/aquatone" ];then
  mkdir $url/aquatone
fi
if [ ! -d "$url/subdomains" ];then
  mkdir $url/subdomains
fi
if [ ! -d "$url/waybackurls" ];then
  mkdir $url/waybackurls
fi
#if [ ! -d "$url/waybackurls/extensions" ];then
#  mkdir $url/waybackurls/extensions
#fi
if [ ! -d "$url/gau" ];then
  mkdir $url/gau
fi
if [ ! -d "$url/httpx" ];then
  mkdir $url/httpx
fi
#if [ ! -d "$url/nuclei-report" ];then
#  mkdir $url/nuclei-reports
#fi
echo "============================================="
echo "[+] Harvesting subdomains with assetfinder..."
echo "============================================="
assetfinder -subs-only $1 | anew $url/subdomains/all-domains.txt

#echo "================================="
#echo "[+] Checking domains with amass.."
#echo "================================="
#amass enum -d $1 -passive -v | anew $url/subdomains/all-domains.txt

echo "==========================================="
echo "[+] Enumerating subdomains with Sublist3r.."
echo "==========================================="
sublist3r -d $1 | anew $url/subdomains/all-domains.txt

echo "================================"
echo "[+] Probing for alive domains..."
echo "================================"
cat $url/subdomains/all-domains.txt | sort -u | httpx | anew $url/httpx/alive-domains.txt

#echo "[+] Enumerating VHosts with ffuf..."
#ffuf -w /opt/SecLists/Discovery/DNS/subdomains-top1million-110000.txt -u $1 -H "Header:FUZZ.$1" | anew $url/subdomains/vhosts.txt

echo "================================="
echo "[+] Fetching all urls with gau..."
echo "================================="
echo $1 | gau | anew $url/gau/gau.txt

echo "======================="
echo "[+] Wayback url check.."
echo "======================="
echo $1 | waybackurls | anew $url/waybackurls/allurls.txt

#echo "=================================="
#echo "[+] Getting possible xss params..."
#echo "=================================="
#cat $url/gau/gau.txt | gf xss | anew $url/gau/gf-xss.txt

#echo "==================================="
#echo "[+] Getting possible sqli params..."
#echo "==================================="
#cat $url/gau/gau.txt | gf sqli | anew $url/gau/gf-sqli.txt

#echo "=================================="
#echo "[+] Getting possible lfi params..."
#echo "=================================="
#cat $url/gau/gau.txt | gf lfi | anew $url/gau/gf-lfi.txt

#echo "===================================="
#echo "[+] checking for xss attack params.."
#echo "===================================="
#cat $url/gau/gf-xss.txt | kxss | anew $url/gau/kxss-out.txt

echo "================================="
echo "[+] Scanning Open Ports with Nmap"
echo "================================="
cat $url/httpx/alive-domains.txt | sort -u | sed 's/https\?:\/\///' | sed 's/http\?:\/\///' | anew $url/nmap-scans/domains.txt
nmap -iL $url/nmap-scans/domains.txt -T4 -A | anew $url/nmap-scans/nmap-results.txt

echo "============================"
echo "[+] Screenshot All domains.."
echo "============================"
cat $url/httpx/alive-domains.txt | aquatone -out $url/aquatone

#echo "==============================="
#echo "[+] Scanning CVEs with Nuclei.."
#echo "==============================="
#nuclei -l $url/httpx/alive-domains.txt -t ~/nuclei-templates/ -o $url/nuclei-reports/nuclei.txt
