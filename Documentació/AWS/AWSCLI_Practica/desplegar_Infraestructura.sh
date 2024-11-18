#!/bin/bash

# Comprovació de paràmetres
ARGS_ESPERATS=3
if [ "$#" -ne $ARGS_ESPERATS ]; then
    echo "Ús: $0 <domini_AD> <nom_server_web> <nombre_clients>"
    echo "Exemple: $0 hackathon.local servidor-web 5 usuaris.txt"
    exit 1
fi

# Assignació de variables des dels paràmetres d'entrada
DOMINI_AD=$1
NOM_SERVER_WEB=$2
NOMBRE_CLIENTS=$3

# Validacions
if [ "$NOMBRE_CLIENTS" -gt 10 ]; then
    echo "Error: El nombre màxim de clients Linux és 10."
    exit 1
fi


# Execució d'scripts per a cada component de la infraestructura
echo "Començant el desplegament de la infraestructura..."

echo "Configurant servidor Windows amb AD..."
./configura_windows_ad.sh "$DOMINI_AD"

echo "Configurant servidor Linux per al servei web..."
./configura_server_web_linux.sh "$NOM_SERVER_WEB" "$DOMINI_AD"

echo "Creant clients Linux..."
./crea_clients_linux.sh "$NOMBRE_CLIENTS" "$NOM_SERVER_WEB"

echo "Desplegament completat."

