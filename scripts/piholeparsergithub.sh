#!/bin/bash
## This will parse lists and upload to Github

## Timestamp
timestamp=`date`

## Colors
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
yellow='\e[1;33m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'
magenta='\e[1;35m%s\e[0m\n'
cyan='\e[1;36m%s\e[0m\n'

## Dependency check
printf "$blue"    "___________________________________________________________"
echo ""
printf "$green"   "Checking Dependencies"
{ if
which p7zip >/dev/null;
then
echo ""
printf "$yellow"  "p7zip is installed"
else
printf "$yellow"  "Installing p7zip"
sudo apt-get install -y p7zip-full
fi }
printf "$magenta" "___________________________________________________________"
echo ""

## Clean directories to avoid collisions
printf "$blue"    "___________________________________________________________"
echo ""
printf "$green"   "Clearing the Path."

if 
ls /etc/piholeparser/lists/*.txt &> /dev/null; 
then
sudo rm /etc/piholeparser/lists/*.txt
else
echo ""
fi

if 
ls /etc/piholeparser/mirroredlists/*.txt &> /dev/null; 
then
sudo rm /etc/piholeparser/mirroredlists/*.txt
else
echo ""
fi

if 
ls /etc/piholeparser/parsed/*.txt &> /dev/null; 
then
sudo rm /etc/piholeparser/parsed/*.txt
else
echo ""
fi

if 
ls /etc/piholeparser/parsedall/*.txt &> /dev/null; 
then
sudo rm /etc/piholeparser/parsedall/*.txt
else
echo ""
fi

if 
ls /etc/piholeparser/compressedconvert/*.7z &> /dev/null; 
then
sudo rm /etc/piholeparser/compressedconvert/*.7z
else
echo ""
fi

if 
ls /etc/piholeparser/compressedconvert/*.tar.gz &> /dev/null; 
then
sudo rm /etc/piholeparser/compressedconvert/*.tar.gz
else
echo ""
fi

if 
ls /etc/piholeparser/compressedconvert/*.txt &> /dev/null; 
then
sudo rm /etc/piholeparser/compressedconvert/*.txt
else
echo ""
fi

if 
ls /var/www/html/compressedconvert/*.txt &> /dev/null; 
then
sudo rm /var/www/html/compressedconvert/*.txt
else
echo ""
fi

printf "$magenta" "___________________________________________________________"
echo ""

## Make sure we are in the correct directory
cd /etc/piholeparser

## Pull new lists on github
printf "$blue"    "___________________________________________________________"
echo ""
printf "$green"   "Updating Repository."
sudo git pull
printf "$magenta" "___________________________________________________________"
echo ""

## Re-Build 1111ALLPARSEDLISTS1111.lst
printf "$blue"    "___________________________________________________________"
echo ""
printf "$green"   "Rebuilding the complete list file."
sudo rm /etc/piholeparser/1111ALLPARSEDLISTS1111.lst
sudo cat /etc/piholeparser/lists/*.lst | sort > /etc/piholeparser/1111ALLPARSEDLISTS1111.lst
printf "$magenta" "___________________________________________________________"
echo ""

## Process lists that have to be extracted
printf "$blue"    "___________________________________________________________"
echo ""
printf "$green"   "Downloading and Extracting Compressed Lists."
sudo bash /etc/piholeparser/compressedconvert.sh
printf "$magenta" "___________________________________________________________"
echo ""

## Parse Lists
echo ""
echo "Parsing Lists."
sudo bash /etc/piholeparser/advancedparser.sh
printf "$magenta" "___________________________________________________________"
echo ""

## Parse Big List
echo ""
echo "Parsing All Lists."
sudo bash /etc/piholeparser/advancedparserlocal.sh
printf "$magenta" "___________________________________________________________"
echo ""
sudo cp /etc/piholeparser/parsedall/*.txt /etc/piholeparser/parsed/

## Cleanup
printf "$blue"    "___________________________________________________________"
echo ""
printf "$green"   "Cleaning Up."

if 
ls /etc/piholeparser/lists/*.txt &> /dev/null; 
then
sudo rm /etc/piholeparser/lists/*.txt
else
echo ""
fi

if 
ls /etc/piholeparser/compressedconvert/*.7z &> /dev/null; 
then
sudo rm /etc/piholeparser/compressedconvert/*.7z
else
echo ""
fi

if 
ls /etc/piholeparser/compressedconvert/*.tar.gz &> /dev/null; 
then
sudo rm /etc/piholeparser/compressedconvert/*.tar.gz
else
echo ""
fi

if 
ls /etc/piholeparser/compressedconvert/*.txt &> /dev/null; 
then
sudo rm /etc/piholeparser/compressedconvert/*.txt
else
echo ""
fi

if 
ls /var/www/html/compressedconvert/*.txt &> /dev/null; 
then
sudo rm /var/www/html/compressedconvert/*.txt
else
echo ""
fi

printf "$magenta" "___________________________________________________________"
echo ""

## Push Changes up to Github
printf "$blue"    "___________________________________________________________"
echo ""
printf "$green"   "Pushing Lists to Github"
sudo git config --global user.name "deathbybandaid"
sudo git config --global user.email sam@deathbybandaid.net
sudo git remote set-url origin https://Deathbybandaid:Bandaid1701@github.com/deathbybandaid/piholeparser.git
sudo git add .
sudo git commit -m "Update lists $timestamp"
sudo git push -u origin master
printf "$magenta" "___________________________________________________________"
echo ""

## Push 1111ALLPARSEDLISTS1111 to localhost
printf "$blue"    "___________________________________________________________"
echo ""
printf "$green"   "Push Changes up to Pihole Web Server"

if 
[ -d "/var/www/html/lists/" ] 
then
echo "" 
else
sudo mkdir /var/www/html/lists/
fi

sudo rm /var/www/html/lists/1111ALLPARSEDLISTS1111.txt
sudo cp -p /etc/piholeparser/parsed/1111ALLPARSEDLISTS1111.txt /var/www/html/lists/1111ALLPARSEDLISTS1111.txt
printf "$magenta" "___________________________________________________________"
echo ""
