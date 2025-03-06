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
[ -d /var/lib/etcd ] || { echo "Error: No existeix /var/lib/etcd"; exit 1; }
[ -d /etc/kubernetes ] || { echo "Error: No existeix /etc/kubernetes"; exit 1; }
[ -d /home/asix/odoo-kubernetes ] || { echo "Error: No existeix /home/asix/odoo-kubernetes"; exit 1; }

# Ara creo l'arxiu de backup i el comprimeixo amb les carpetes necessaries
echo "Comprimint..."
sudo tar -czf $FITXER /var/lib/etcd /etc/kubernetes /home/asix/odoo-kubernetes

# Transfereixo el fitxer comprimit i l'envio amb scp a on haguem posat a la part de dalt del programa
echo "Enviant..."
scp -i $CLAU_SSH $FITXER $USUARI_REMOT@$DESTI_IP:$DIRECTORI_REMOT

# FInalment elimino els arxius locals de backup un cop la transferencia esta feta aixi no n'acumulem
echo "Esborrant temporal..."
rm $FITXER

# COnfirmació final amb la ruta del backup remot
echo "Tot correcte! Backup guardat a:"
echo "$USUARI_REMOT@$DESTI_IP:$DIRECTORI_REMOT$FITXER"
