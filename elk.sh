#!/bin/sh

pInfo() {
    if [ "$#" -ne 1 ]; then
        echo "Invalid arguments: pInfo needs one string as argument."
        exit 1
    fi
    echo "\033[32m[INFO]\033[0m $1"
}

pError() {
    if [ "$#" -ne 1 ]; then
        echo "Invalid arguments: pError needs one string as arguments."
        exit 1
    fi
    echo "\033[31m[ERROR]\033[0m $1"
}

install_elk() {
    wget "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.2.deb" -q --show-progress
    sudo dpkg -i "elasticsearch-6.4.2.deb"
    sudo apt-get install -f
    sudo rm -rRf "elasticsearch-6.4.2.deb"
}

which grep
echo $PATH
pInfo "Verifying ElasticSearch installation."
status=$(dpkg -s elasticsearch | grep Status)
if [ "$?" -ne 0 ] || [ -z "$status" ]; then
    pError "ElasticSearch is not installed."
    pInfo "Start the installation ? (y/n)"
    read answer
    if [ "$answer" != "y" ] && [ "$answer" != "n" ]; then
        pError "Invalid answer. Just type 'y' (yes) or 'n' (no)."
        exit 1
    fi
    if [ "$answer" = "y" ]; then
        pInfo "Installing ElasticSearch..."
        install_elk
    else
        pInfo "Not installing ElasticSearch."
        exit 2
    fi
fi

pInfo "ElasticSearch installed."

ps ax | grep -v grep | grep "elasticsearch" > /dev/null
if [ "$?" -eq 1 ]; then
    pInfo "ElasticSearch not running. Starting..."
    if [ ! -z "$(ps -p 1 | grep "systemd")" ]; then
        pInfo "System running systemd."
        sudo systemctl start elasticsearch.service
    else
        pInfo "System running init."
        sudo -i service elasticsearch start
    fi
fi

pInfo "ElasticSearch started."

exit 0
