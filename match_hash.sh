#!/bin/sh

install_elasticsearch() {
    wget "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.2.deb" -q --show-progress
    sudo dpkg -i "elasticsearch-6.4.2.deb"
    sudo apt-get install -f
    sudo rm -rRf "elasticsearch-6.4.2.deb"
}

if [ "$#" -ne 6 ]; then
    echo "[ERROR] Usage: ./match_hash -m <mode> -f <file to filter> -c <source>"
    exit 1
fi

if [ "$1" != "-m" ] || [ "$3" != "-f" ] || [ "$5" != "-c" ]; then
    echo "[ERROR] Invalid options: ./match_hash -m <mode> -f <file to filter> -c <source>"
    exit 2
fi

if [ "$2" != "g" ] && [ "$2" != "b" ]; then
    echo "[ERROR] Invalid mode: only 'b' (bad filter) or 'g' (good filter)"
    exit 3
fi

if [ -z $(echo "$4" | grep "[^.]*.csv") ]; then
    echo "[ERROR] Invalid file. Need a .csv file to analyse."
    exit 4
fi

if [ -z $(echo "$6" | grep "[^.]*.csv") ]; then
    echo "[ERROR] Invalid file. Need a .csv file as the source."
    exit 5
fi

if [ ! -f "$4" ]; then
    echo "[ERROR] File $4 not found."
    exit 6
fi

if [ ! -f "$6" ]; then
    echo "[ERROR] File $6 not found."
    exit 7
fi

echo "[INFO] Verify ElasticSearch installation."
status=$(dpkg -s elasticsearch | grep Status)
deinstall=$(echo "$status" | grep "deinstall")
if [ "$?" -ne 0 ] || [ ! -z "$deinstall" ]; then
    echo "[ERROR] ElasticSearch is not installed."
    echo "[INFO] Start the installation? (y/n)"
    read answer
    if [ "$answer" != "y" ] && [ "$answer" != "n" ]; then
        echo "[ERROR] Invalid answer. Just type 'y' (yes) or 'n' (no)"
        exit 8
    fi
    if [ "$answer" = "y" ]; then
        install_elasticsearch
    else
        echo "[INFO] Not installing ElasticSearch."
        exit 9
    fi
fi

echo "[INFO] ElasticSearch installed."

ps ax | grep -v grep | grep "elasticsearch" > /dev/null
if [ "$?" -eq 1 ]; then
    echo "[INFO] ElasticSearch not running. Starting."
    if [ ! -z "$(ps -p 1 | grep "systemd")" ]; then
        echo "[INFO] System running systemd."
        sudo systemctl start elasticsearch.service
    else
        echo "[INFO] System running init."
        sudo -i service elastisearch start
    fi
fi 

echo "[INFO] ElasticSearch started."

exit 0
