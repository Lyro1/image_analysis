#!/bin/sh

force=0

if [ "$#" -gt 1 ]; then
	echo "Usage: ./install_plaso.sh <option>"
	exit 1
fi

if [ "$#" -eq 1 ]; then
	if [ "$1" -eq "-f" ]; then
		force=1
	fi 
fi

echo "Downloading and installing all the dependencies."
sudo apt-get install build-essential autotools-dev libsqlite3-dev python-dev debhelper devscripts fakeroot quilt git mercurial python-setuptools libtool automake -y

if [ "$?" -ne 0 ]; then
	echo "Error: failed to get all the dependencies."
	exit 4
fi

if [ ! -f "plaso-20180818.tar.gz" || "$force" -eq 1 ]; then
	wget "https://github.com/log2timeline/plaso/releases/download/20180818/plaso-20180818.tar.gz"
	if [ "$?" -ne 0 ]; then
		echo "Error: failed to download the plaso package."
		exit 5
	fi

	echo "Sucesfully downloaded the plaso package."
else
	echo "Plaso package already downloaded"
fi

tar zxvf plaso-20180818.tar.gz
if [ "$?" -ne 0 ]; then
	echo "Failed to extract the plaso package."
	exit 6
fi

echo "Sucesfully extracted the plaso package."

cp -rf plaso-20180818/config/dpkg plaso-20180818/debian

if [ "$?" -ne 0 ]; then
	echo "Failed to move the config/dpkg folder to debian folder."
	exit 7
fi

echo "Sucesfully moved the config/dpkg folder to debian"

PYTHONPATH=l2tdevtools l2tdevtools/tools/dpkg-generate.py --source-directory=. plaso-20180818.tar.gz
mv dpkg debian

// La ligne au dessus ne fonctionne pas encore (cf mail au développeur). 

exit 0
