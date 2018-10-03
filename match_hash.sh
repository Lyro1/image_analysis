#!/bin/sh

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

# TODO: Verifier que ElasticSearch est installé
# Si non : installer
# Si oui : Verifier que ElasticSearch est allumé
#          Si non : allumer
#          Si oui : checker le mode
#                   Si le mode est 'g' : supprimer du csv toutes les entrées
#                                        qui matchent la source
#                   Si le mode est 'b' : ne guarder que les entrées qui 
#                                        matchent la source
#
exit 0
