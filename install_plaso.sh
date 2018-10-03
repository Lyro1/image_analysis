#!/bin/sh

echo "Verifying dependencies."
sudo apt-get install curl

get_latest_release() {
   curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'
}

echo "\nGetting the latest release of Plaso."
release=$(get_latest_release "log2timeline/plaso")
echo "Latest Plaso release is $release."

echo "Trying to download the archive."
sudo rm -rR "plaso-$release.tar.gz"
wget "https://github.com/log2timeline/plaso/releases/download/$release/plaso-$release.tar.gz" -q --show-progress

if [ "$?" -ne 0 ]; then
    echo "[ERROR] Failed to download the archive plaso-$release.tar.gz"
    exit 1
fi

echo "Successfully downloaded the archive plaso-$release.tar.gz"

echo "Trying to extract the archive."
tar -xzf plaso-$release.tar.gz
if [ "$?" -ne 0 ]; then
    echo "[ERROR] Failed to extract plaso-$release.tar.gz"
    rm -rR "plaso-$release.tar.gz"
    exit 2
fi

echo "Removed the archive after extraction."
rm -rR "plaso-$release.tar.gz"
