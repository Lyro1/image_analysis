#!/bin/sh

getRealNames() {
    sudo touch "$2"
    sudo chmod 666 "$2"
    i=0
    while IFS='' read -r hash file; do
        grep -i "$hash" "$3" >> "$2"
        i=$((i+1))
        echo "$i/$4"    
    done < "$1"
}

echo "[INFO] Checking dependencies..."
sudo apt-get install md5deep
echo "[INFO] Dependencies checked."
clear

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

if [ -z $(pstree |grep 'nsrlsvr') ]; then
    echo "[INFO] Installing the hash set."
    sudo nsrlupdate "set/NSRLFile.txt"

    echo "[INFO] Starting the NSRL Server"
    nsrlsvr
fi

echo "[INFO] NSRL Server started."

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

echo "[INFO] NSRL Client started."

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

# Creates the hash_outputs folder with full rights
sudo mkdir "hash_outputs" -p
sudo chmod 777 "hash_outputs"

# Creates the results files in the hash_outputs folder
resfile="hash_outputs/$resname-$date-1.txt"
resfinal="hash_outputs/$resname-$date.csv"
sudo touch "$resfinal"

# Run nsrllookup and save the output in resfile
res=$(nsrllookup < "$hashfile" > "$resfile")

# Count how many unknown files have been found
unknownfiles=$(wc -l "$resfile" | awk '{ print $1 }')

# Inform the user of the number of unknown files
echo "[INFO] Saved the result in $resfinal"
if [ "$unknownfiles" -ne 0 ]; then
    echo "\033[31m[WARN] Found $unknownfiles unknown files.\033[0m"
else
    echo "[INFO] Found no unknown files."
fi

# Getting understandable lines in the output file
echo "[INFO] Getting files names."
getRealNames "$resfile" "$resfinal" "binaries_corrected_whead.csv" "$unknownfiles"

echo "[INFO] Remove trash files."
#sudo rm -rRf "hashfile.txt" "$resfile"
echo "[INFO] Analyse complete."

exit 0
