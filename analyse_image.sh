#!/bin/sh

if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
    echo "[ERROR] Usage: ./image_analyse.sh <image>"
    exit 1
fi

echo "[INFO] Verify that Plaso is installed."

if [ -z $(find . -maxdepth 1 -type d -name 'plaso-*' -print -quit) ]; then
    echo "[ERROR] Plaso is not installed. Please run install_plaso.sh and try again"
    exit 2
fi

echo "[INFO] Plaso is installed."

echo "[INFO] Resolving Artifacts definitions."
git clone https://github.com/ForensicArtifacts/artifacts
if [ "$?" -ne 0 ]; then
    echo "[ERROR] Failed to get the latest Artifacts definitions."
    exit 3
fi

yes | sudo cp -rf artifacts/data/* /usr/share/artifacts
if [ "$?" -ne 0 ]; then
    echo "[ERROR] Failed to install the latest Artifacts definitions."
    exit 6
fi

sudo rm -Rrf artifacts
echo "[INFO] Successfully installed the latest Artifacts definitions."

echo "[INFO] Generating the Plaso file for the provided image"
log2timeline.py "outputs/$1-result.plaso" "$1"

if [ "$?" -ne 0 ]; then
    echo "[ERROR] Failed to generate Plaso file."
    exit 4
fi

echo "[INFO] Generated outputs/$1-result.plaso."
echo "[INFO] Analysing the result file."

psort.py -w "outputs/$1-result.log" "outputs/$1-result.plaso"

if [ "$?" -ne 0 ]; then
    echo "[ERROR] Failed to analyse the result file."
    exit 5
fi

echo "[INFO] Generated outputs/$1-result.log with the analyse results"

exit 0
