#!/bin/sh

sudo apt-get install python-lzma

if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
    echo "[ERROR] Usage: ./analyse_image.sh <image>"
    exit 1
fi

echo "[INFO] Verify that Plaso is installed."

if [ -z $(find . -maxdepth 1 -type d -name 'plaso-*' -print -quit) ]; then
    echo "[ERROR] Plaso is not installed."
    echo "[INFO] Start the installation? (y/n)"
    read answer
    if [ "$answer" != "y" ] && [ "$answer" != "n" ]; then
        echo "[ERROR] Invalid answer. Just type 'y' (yes) or 'n' (no)"
        exit 2
    fi
    if [ "$answer" = "y" ]; then
        ./install_plaso.sh
    else
        echo "[INFO] Not installing Plaso."
        exit 3
    fi
fi

echo "[INFO] Plaso is installed."

echo "[INFO] Generating the Plaso file for the provided image"
mkdir -p outputs
img_name=$(echo "$1" | rev | cut -d '/' -f 1 | rev)
date=$(date "+%d%m%y-%H%M%S")

log2timeline.py outputs/$img_name-$date-result.plaso $1 --artifact_definitions artifacts-20180827/data

if [ "$?" -ne 0 ]; then
    echo "[ERROR] Failed to generate Plaso file."
    exit 4
fi

echo "[INFO] Generated outputs/$1-result.plaso."
echo "[INFO] Analysing the result file."

psort.py -w "outputs/$img_name-$date-result.txt" "outputs/$img_name-$date-result.plaso"

if [ "$?" -ne 0 ]; then
    echo "[ERROR] Failed to analyse the result file."
    exit 5
fi

echo "[INFO] Generated outputs/$img_name-$date-result.txt with the analyse results"

exit 0
