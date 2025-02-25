#!/bin/sh

# Configuració
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_FILE="backup-${TIMESTAMP}.tar.gz"
DIRECTORIS_BACKUP="/var/lib/etcd /etc/kubernetes /home/asix/odoo-kubernetes"

# Configuració SCP
# Verificar directoris

# Crear backup comprimit
echo "Creant backup ${BACKUP_FILE}..."
sudo tar -czf "${BACKUP_FILE}" $DIRECTORIS_BACKUP || exit 1
