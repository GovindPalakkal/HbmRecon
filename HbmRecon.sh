#!/bin/bash

########################################
# ///    T00l By D3LT4                 \\\
#  ---------->HBM<----------
#
#
########################################

#colors

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
reset=`tput sgr0`

if [ -d ~/recon/ ]
then
  echo " "
else
  mkdir ~/recon

fi

if [ -d ~/recon/$1 ]
then
  echo " "
else
  mkdir ~/recon/$1

fi


echo "${magenta}
  |---------------------------------------------------------------------------------------|
  |              _   _ _                 ____                        _        ___         |
  |             | | | | |__  _ __ ___   |  _ \ ___  ___ ___  _ __   / |      / _ \        |
  |             | |_| |  _ \| '_   _ \  | |_) / _ \/ __/ _ \|  _ \  | |     | | | |       |
  |             |  _  | |_) | | | | | | |  _ <  __/ (_| (_) | | | | | |  _  | |_| |       |
  |             |_| |_|_ __/|_| |_| |_| |_| \_\___|\___\___/|_| |_| |_| (_)  \___/        |
  |                                                             - T00l BY D3LT4           |
  |         follow on:                                                                    |
  |               github.com/GovindPalakkal        twitter.com/__D3LT4__                  |
  |                                                                                       |
  |---------------------------------------------------------------------------------------|
${reset}"



echo "${red}   [+] Recon Started ..... ${reset}"
echo " ${magenta} Note: you need to install Nahamsec lazyrecon-tools ${reset}"
echo "${yellow} Note: Please set your Censys API ID and secret from your environment (CENSYS_API_ID and CENSYS_API_SECRET) or from the command line
to run Censys ${reset}"
echo "${blue}Check /recon/domain for more details.... ${reset}"
#assefinder
assetfinder -subs-only $1  >> ~/recon/$1/assetfinder.txt

echo " "
echo "${green}  [+] Succesfully saved to assetfinder.txt  ${reset}"


echo " "
echo "${blue} [+] Checking for Subdomians in Amass.....  ${reset}"

#amass

if [ -d ~/tools/Amass/ ]
then
  echo "${yellow} [+] Skipping installation....  ${reset}"
  echo "{$magenta} [+] Running Amass ... ${reset}"
  sudo  amass enum --passive -d $1 > ~/recon/$1/amass.txt
else
  echo " ${green} Amass not found ... "
  echo " ${blue} installing Amass.. please wait "

  sudo git clone https://github.com/OWASP/Amass.git ~/tools/Amass
  echo "{$magenta [+] Running Amass ... ${reset}"
  echo "${blue} [+] Hang tight... sub_domains loading..  ${reset}"
  sudo  amass enum --passive -d $1 > ~/recon/$1/amass.txt

fi

#Sublistor
 echo "${yellow} ------------------------------------- xxxxxxxx ------------------------------------- ${reset}"
echo " ${magenta}Checking on Sublist3r... ${reset}"

if [ -d ~/tools/Sublist3r/ ]
then
  echo "${yellow} [+] Skipping installation....  ${reset}"
  echo "{$magenta [+] Running Sublist3r ... ${reset}"
    python ~/tools/Sublist3r/sublist3r.py -d $1 -t 10 -v -o ~/recon/$1/sublist3r.txt > /dev/null
else
  echo " ${green}  Sublist3r not found ... "
  echo " ${blue} installing Sublist3r.. please wait ${reset}"
  echo "{$magenta} [+] Running Sublist3r ... ${reset}"
  git clone https://github.com/aboul3la/Sublist3r.git ~/tools/Sublist3r/

  python ~/tools/Sublist3r/sublist3r.py -d $1 -t 10 -v -o ~/recon/$1/sublist3r.txt > /dev/null

fi


echo "${blue}------------------------------------- xxxxxxxx ------------------------------------- ${reset}"

#aquatone
echo "${yellow} [+] Checking on Aquatone.. ${reset}"
if [ -d ~/aquatone/ ]
then
        echo "${magenta} [+]  Running Aquatone... ${reset}"
        aquatone-discover -d $1
else
        echo "${green} Aquatone no installed.. ${reset}"
        echo "${magenta} Please wait while installing Aquatone ${reset} "
        sudo gem install aquatone
        echo "${blue} Aquatone succesfully installed ${reset}"
        echo " ${red} Running Aquatone... ${reset} "

        aquatone-discover -d $1
fi


cat ~/aquatone/$1/hosts.txt | cut -d "," -f 1 >> ~/recon/$1/aquatone.txt

#censys

if [ -d ~/tools/censys_sub/ ]
then
  echo "${yellow} [+] Skipping installation....  ${reset}"
  echo "{$magenta [+] Running Censys_subdomain_finder ... ${reset}"
  python ~/tools/censys_sub/censys_subdomain_finder.py $1 -o ~/recon/$1/censys.txt
else
  echo " ${green} Censys_subdomain_finder not found ... "
  echo " ${blue} installing Censys_subdomain_finder.. please wait "
  git clone https://github.com/christophetd/censys-subdomain-finder.git ~/tools/censys_sub/
  pip install -r ~/tools/censys_sub/requirements.txt
  python ~/tools/censys_sub/censys_subdomain_finder.py $1 -o ~/recon/$1/censys.txt

fi



echo "------------------------------------- xxxxxxxx ------------------------------------- "
echo " "
echo "${green}  [+] fetching out unique.. domians...."
echo ""
echo "------------------------------------- xxxxxxxx ------------------------------------- "
echo ""
cat ~/recon/$1/censys.txt ~/recon/$1/aquatone.txt ~/recon/$1/sublist3r.txt ~/recon/$1/assetfinder.txt ~/recon/$1/amass.txt | sort -u >> ~/recon/$1/unique_subdomians.txt

cat ~/recon/$1/unique_subdomians.txt

echo "${yellow}------------------------------------- xxxxxxxx ------------------------------------- "

echo ""
echo "${yellow}  [+] Succesfully saved to unique.txt ${reset}"
echo ""
echo " ------------------------------------- xxxxxxxx ------------------------------------- "

echo "${blue} Taking web screenshots ... please wait... "

if [ -d ~/tools/webscreenshot/ ]
then
  echo "${yellow} [+] Skipping installation....  ${reset}"
  echo "{$magenta} [+] Running Webscreenshot ... ${reset}"
  python ~/tools/webscreenshot/webscreenshot.py -i ~/recon/$1/unique_subdomians.txt
else
  echo " ${green} Webscreenshot not found ... "
  echo " ${blue} installing  Webscreenshot.. please wait "
  git clone https://github.com/maaaaz/webscreenshot.git ~/tools/webscreenshot/
  pip install -r ~/tools/webscreenshot/requirements.txt
  python ~/tools/webscreenshot/webscreenshot.py -i ~/recon/$1/unique_subdomians.txt

fi

echo " ${red} Screenshot completed.. saving.. ${reset} "

echo "${blue} ------------------------------------- xxxxxxxx ------------------------------------- ${reset}"

echo " ${yellow} [+] Directory Bruteforcing Started.... ${reset} "

if [ -d ~/tools/dirsearch/ ]
then
  echo " "
else
  echo "${blue} [+] Dirsearch not found .... installing Dirsearch ${reset}"
  git clone https://github.com/maurosoria/dirsearch.git ~/tools/dirsearch/

fi

if [ -d ~/recon/$1/dirsearch ]
then
  echo " "
else
  mkdir ~/recon/$1/dirsearch

fi

for domains in $(cat ~/recon/$1/unique_subdomians.txt);
do
  sudo python3 ~/tools/dirsearch/dirsearch.py -u $domains -e /,php,html,asp,aspx,backup,sql,zip,rar,mysql,git --plain-text-report ~/recon/$1/dirsearch/$domains.txt
  echo "${red} The files are saved inside /dirsearch/domians.txt Check it out.. ${reset}"
  echo "${green}------------------------------------- xxxxxxxx ------------------------------------- ${reset}"

done

echo "${blue}------------------------------------- xxxxxxxx ------------------------------------- ${reset}"

echo "${magenta} Finding Broken Links ...${reset}"


if [ -d /usr/local/lib/node_modules/broken-link-checker/ ]
then
  echo "${yellow} [+] Skipping installation....  ${reset}"
  echo "{$magenta} [+] Running Broken link Finder... ${reset}"

else
  echo " ${green} Broken Link Finder not found ... "
  echo " ${blue} installing  Broken link Finder.. please wait "
  echo "${red}Note: need to install node js first ${reset}"
  npm install broken-link-checker -g
fi

for domains in $(cat ~/recon/$1/unique_subdomians.txt );
do
   blc https://$domains -ro

done

echo "${yellow} Scanning For Open Ports.. ${reset}"
echo "${blue} Scanning Started................"
echo "${yellow}------------------------------------- xxxxxxxx ------------------------------------- ${reset} "
nmap -iL ~/recon/$1/unique_subdomians.txt -oN ~/recon/$1/nmap_scan.txt
echo "${yellow}------------------------------------- xxxxxxxx ------------------------------------- ${reset}"

echo ""

echo "${red}------------------------------------- xxxxxxxx ------------------------------------- ${reset}"
echo " ${green} -------->Thanks For Using .. Have Good Day<---------------- ${reset}"
echo "${red}------------------------------------- xxxxxxxx ------------------------------------- ${reset}"
