#!/bin/sh

# Configuració de la connexió SSH i directoris per al backup
DESTI_IP="192.168.1.100"          
USUARI_REMOT="root"               
CLAU_SSH="/root/.ssh/id_rsa"      # Ruta completa a la clau SSH
DIRECTORI_REMOT="/backups/"       # Ruta completa al directori remot

# Aquí genero la data per el nom del fitxer de backup agafant (any, mes, dia, hora, minut i segon) pk no hi hagi cap igual
DATA=$(date +%Y%m%d-%H%M%S)
FITXER="backup-$DATA.tar.gz"

# Comprovar directoris locals abans de fer el backup si falta algun d'aquests directoris acaba el programa
echo "Comprovant carpetes..."
if [ ! -d /var/lib/etcd ]; then
    echo "Error: No existeix /var/lib/etcd"
    exit 1
fi

if [ ! -d /etc/kubernetes ]; then
    echo "Error: No existeix /etc/kubernetes"
    exit 1
fi

if [ ! -d /home/asix/odoo-kubernetes ]; then
    echo "Error: No existeix /home/asix/odoo-kubernetes"
    exit 1
fi

# Ara creo l'arxiu de backup i el comprimeixo amb les carpetes necessaries
sudo tar -czf "$FITXER" /var/lib/etcd /etc/kubernetes /home/asix/odoo-kubernetes
if [ $? -ne 0 ]; then
    echo "ERROR: La compressió ha fallat (codi d'error: $?)"
    exit 1
fi

# Transfereixo el fitxer comprimit i l'envio amb scp a on haguem posat a la part de dalt del programa
scp -i "$CLAU_SSH" "$FITXER" "$USUARI_REMOT@$DESTI_IP:$DIRECTORI_REMOT"
if [ $? -ne 0 ]; then
    echo "ERROR: Fallida en el transferiment a $DESTI_IP (codi d'error: $?)"
    exit 1
fi

# FInalment elimino els arxius locals de backup un cop la transferencia esta feta aixi no n'acumulem
rm "$FITXER"
if [ $? -ne 0 ]; then
    # En aquest cas falla l'esborrat
    echo "El Backup s'ha enviat correctament, però hi ha hagut un error al borrar-ho localment (codi $?)"
else
    # Aqui ha funcionat tot
    echo "Finalmnet el Backup s'ha executat correctament i s'han fet totes les operacions amb èxit"
fi
