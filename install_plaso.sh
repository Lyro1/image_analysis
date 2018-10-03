#!/bin/sh

echo "Getting the l2tdevtools to install Plaso."
sudo rm -rR l2tdevtools
git clone https://github.com/log2timeline/l2tdevtools.git
if [ "$?" -ne 0 ]; then
    echo "Error: failed to clone the l2tdevtools repository."
    exit 1
fi
echo "Successfully cloned the l2tdevtools repository."

cd l2tdevtools

echo "Getting the pre-requisites dependencies."
sudo apt-get install build-essential autoconf automake autopoint libtool gettext pkg-config debhelper devscripts fakeroot quilt autotools-dev zlib1g-dev libbz2-dev libssl-dev libfuse-dev libfuse-dev python-dev python-setuptools flex byacc python3-all python3-setuptools python3-all-dev liblzma-dev python-pbr python3-pbr python-setuptools-scm python3-setuptools-scm -y

echo "Building target dpkg."
PYTHONPATH=. python tools/build.py --preset plaso dpkg

cd build
echo "Built all the packages."
