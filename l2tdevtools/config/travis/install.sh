#!/bin/bash
#
# Script to set up Travis-CI test VM.

L2TBINARIES_DEPENDENCIES="";

L2TBINARIES_TEST_DEPENDENCIES="";

PYTHON2_DEPENDENCIES="pylint";

PYTHON2_TEST_DEPENDENCIES="python-coverage";

PYTHON3_DEPENDENCIES="";

PYTHON3_TEST_DEPENDENCIES="pylint";

# Exit on error.
set -e;

if test ${TRAVIS_OS_NAME} = "osx";
then
	git clone https://github.com/log2timeline/l2tbinaries.git -b dev;

	mv l2tbinaries ../;

	for PACKAGE in ${L2TBINARIES_DEPENDENCIES};
	do
		echo "Installing: ${PACKAGE}";
		sudo /usr/bin/hdiutil attach ../l2tbinaries/macos/${PACKAGE}-*.dmg;
		sudo /usr/sbin/installer -target / -pkg /Volumes/${PACKAGE}-*.pkg/${PACKAGE}-*.pkg;
		sudo /usr/bin/hdiutil detach /Volumes/${PACKAGE}-*.pkg
	done

	for PACKAGE in ${L2TBINARIES_TEST_DEPENDENCIES};
	do
		echo "Installing: ${PACKAGE}";
		sudo /usr/bin/hdiutil attach ../l2tbinaries/macos/${PACKAGE}-*.dmg;
		sudo /usr/sbin/installer -target / -pkg /Volumes/${PACKAGE}-*.pkg/${PACKAGE}-*.pkg;
		sudo /usr/bin/hdiutil detach /Volumes/${PACKAGE}-*.pkg
	done

elif test ${TRAVIS_OS_NAME} = "linux";
then
	sudo rm -f /etc/apt/sources.list.d/travis_ci_zeromq3-source.list;

	sudo add-apt-repository ppa:gift/dev -y;
	sudo apt-get update -q;

	if test ${TRAVIS_PYTHON_VERSION} = "2.7";
	then
		sudo apt-get install -y ${PYTHON2_DEPENDENCIES} ${PYTHON2_TEST_DEPENDENCIES};
	else
		sudo apt-get install -y ${PYTHON3_DEPENDENCIES} ${PYTHON3_TEST_DEPENDENCIES};
	fi
fi
