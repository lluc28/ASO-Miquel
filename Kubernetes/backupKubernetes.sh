#!/bin/sh

# DADES FIXES
DESTI_IP="192.168.1.100"          # Posar la IP real aquí
USUARI_REMOT="root"               # Posar usuari remot aquí
CLAU_SSH="/root/.ssh/id_rsa"      # Ruta completa a la clau SSH
DIRECTORI_REMOT="/backups/"       # Ruta completa al directori remot

# 
DATA=$(date +%Y%m%d-%H%M%S)
FITXER="backup-$DATA.tar.gz"

# Comprovar directoris locals
echo "Comprovant carpetes..."
[ -d /var/lib/etcd ] || { echo "Error: No existeix /var/lib/etcd"; exit 1; }
[ -d /etc/kubernetes ] || { echo "Error: No existeix /etc/kubernetes"; exit 1; }
[ -d /home/asix/odoo-kubernetes ] || { echo "Error: No existeix /home/asix/odoo-kubernetes"; exit 1; }

# Fer el backup
echo "Comprimint..."
sudo tar -czf $FITXER /var/lib/etcd /etc/kubernetes /home/asix/odoo-kubernetes

# Enviar
echo "Enviant..."
scp -i $CLAU_SSH $FITXER $USUARI_REMOT@$DESTI_IP:$DIRECTORI_REMOT

# Netejar
echo "Esborrant temporal..."
rm $FITXER

echo "Tot correcte! Backup guardat a:"
echo "$USUARI_REMOT@$DESTI_IP:$DIRECTORI_REMOT$FITXER"
