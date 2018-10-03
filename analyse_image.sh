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
