#!/bin/sh

echo "[INFO] Verifying script requirements."
sudo apt-get -q -y install curl

echo "\n[INFO] Requirements verified."

get_latest_release() {
   curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'
}

echo "[INFO] Getting the latest release of Plaso."
release=$(get_latest_release "log2timeline/plaso")
echo "[INFO] Latest Plaso release is $release."

echo "[INFO] Trying to download the archive."
sudo rm -rRf "plaso-$release.tar.gz"
wget "https://github.com/log2timeline/plaso/releases/download/$release/plaso-$release.tar.gz" -q --show-progress

if [ "$?" -ne 0 ]; then
    echo "[ERROR] Failed to download the archive plaso-$release.tar.gz"
    exit 1
fi

echo "[INFO] Successfully downloaded the archive plaso-$release.tar.gz"

echo "[INFO] Trying to extract the archive."
sudo rm -rfR "plaso-$release"
tar -xzf plaso-$release.tar.gz
if [ "$?" -ne 0 ]; then
    echo "[ERROR] Failed to extract plaso-$release.tar.gz"
    rm -rR "plaso-$release.tar.gz"
    exit 2
fi

echo "[INFO] Removed the archive after extraction."
rm -rR "plaso-$release.tar.gz"

echo "[INFO] Building the dependencies."
cd "plaso-$release"
sudo rm -rRf requirements.txt
wget "https://raw.githubusercontent.com/log2timeline/plaso/master/requirements.txt"
python -m pip install -r requirements.txt

echo "[INFO] Verifying that __init__.py file exists."
if [ ! -f "utils/__init__.py" ]; then
    touch "utils/__init__.py"
fi
echo "[INFO] Verification done."

echo "[INFO] Installation done."
echo "[INFO] Verify that all dependencies are installed by running the check_dependencies.py script"

exit 0
