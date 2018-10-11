#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "[ERROR] Usage:"
    echo "To analyse a hash collectio file:"
    echo "   ./match_hash.sh -f <filename>"
    echo "To analyse a directory:"
    echo "   ./match_hash.sh -d <directoryname>" 
    exit 1   
fi

if [ "$1" != "-f" ] && [ "$1" != "-d" ]; then
    echo "[ERROR] Usage:"
    echo "To analyse a hash collection file:"
    echo "   ./match_hash.sh -f <filename>"
    echo "To analyse a directory:"
    echo "   ./match_hash.sh -d <directoryname>"
    exit 1
fi

if [ "$1" = "-f" ] && [ ! -f "$2" ]; then
    echo "[ERROR] Invalid filename: can't find $2"
    exit 2
fi

if [ "$1" = "-d" ] && [ ! -d "$2" ]; then
    echo "[ERROR] Invalid directory: can't find $2"
    exit 3
fi

echo "[INFO] Checking for the NSRL Server."
if [ ! -d "nsrlsvr" ]; then
    echo "[INFO] NSRL Server not installed. Installing."
    sudo apt-get install libboost-all-dev python3.5 -y
    wget https://github.com/rjhansen/nsrlsvr/tarball/master -q --show-progress
    tar xzf master
    sudo rm master
    mv rjhansen* nsrlsvr
    cd nsrlsvr
    cmake -DPYTHON_EXECUTABLE='which python3' .
    sudo make
    sudo make install
    cd .. 
    echo "[INFO] NSRL Server installed."
fi

echo "[INFO] Starting NSRL Server."
nsrlsvr

echo "[INFO] Getting the last version of NSRL RDS hash set."
sudo mkdir set -p
wget https://nist.gov/itl/ssd/software-quality-group/nsrl-download/current-rds-hash-sets -q --show-progress
sudo mv current-rds-hash-sets set

echo "[INFO] Checking for the NSRL Client."
if [ ! -d "nsrllookup" ]; then
    echo "[INFO] NSRL Client not installed. Installing."
    git clone https://github.com/rjhansen/nsrllookup.git
    cd nsrllookup
    cmake -D CMAKE_BUILD_TYPE=Release .
    sudo make
    sudo make install
    cd ..
    echo "[INFO] NSRL Client installed."
fi

echo "[INFO] Checking md5deep package."
sudo apt-get install md5deep

echo "[INFO] Starting the filtering of $2"

hashfile="$2"
if [ "$1" = "-d" ]; then
    sudo md5deep -r "$2" > hashfile.txt
    hashfile="hashfile.txt"
    numberoffiles=$(wc -l "$hashfile" | awk '{ print $1 }')
    echo "[INFO] Found $numberoffiles files in $2"
fi
name="$2"
lastchar=$(echo -n "$name" | tail -c 1)
if [ "$lastchar" = "/" ]; then
    name=$(echo "$name" | sed 's/.$//')
fi

resname=$(echo "$name" | rev | cut -d '/' -f 1 | rev)
date=$(date "+%d%m%y-%H%M%S")
sudo mkdir "hash_outputs" -p

res=$(nsrllookup < "$hashfile")
resfile="hash_outputs/$resname-$date-1.txt"
resfinal="hash_outputs/$resname-$date.txt"
sudo touch "$resfile"
sudo touch "$resfinal"
sudo chmod 666 "$resfile"
sudo chmod 666 "$resfinal"
echo "[INFO] Created $resfinal"
sudo echo "$res" >> "$resfile"
sudo chmod 644 "$resfile"
echo "[INFO] Saved the result in $resfinal"

echo "[INFO] Getting files names."
while IFS='' read -r line; do
    name=$(grep -i "$line" "$hashfile")
    if [ ! -z "$name" ]; then
        echo "$name" >> "$resfinal"
    fi
done < "$resfile"
sudo chmod 644 "$resfinal"

echo "[INFO] Remove trash files."
sudo rm -rRf set "hashfile.txt" "$resfile"
unknownfiles=$(wc -l "$resfinal" | awk '{ print $1 }')
echo "[INFO] Analyse complete."
echo "[INFO] $unknownfiles unknown files were found."

exit 0
