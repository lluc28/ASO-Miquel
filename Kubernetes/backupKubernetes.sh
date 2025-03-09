#!/bin/sh

# Configuració de la connexió SSH i directoris per al backup
DESTI_IP="192.168.1.100"          
USUARI_REMOT="root"               
CLAU_SSH="/root/.ssh/id_rsa"      # Ruta completa a la clau SSH
DIRECTORI_REMOT="/backups/"       # Ruta completa al directori remot
LOG_FILE="/var/log/backup/historic.log" # Ruta fitxer de logs

# Aqui carrego la configuració externa del fitxer backup.conf
CONFIG_FILE="/etc/backup.conf"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Fitxer de configuració no trobat: $CONFIG_FILE" >&2
    exit 1  # Nou codi d'error per configuració faltant
fi
source "$CONFIG_FILE"

# Si el fitxer log passa de la mida màxima que es defineix al fitxer backup.conf el fitxer log es renombra i es crea un nou fitxer amb el mateix nom que l'original
MIDA_ACTUAL=$(wc -c < "$LOG_FILE" 2>/dev/null)
if [ "$MIDA_ACTUAL" -ge "$LOG_MAX_MIDA" ]; then
    NOU_NOM="/var/log/backup/historic-$(date +%Y%m%d-%H%M%S).log"
    mv "$LOG_FILE" "$NOU_NOM"
    touch "$LOG_FILE"
    chmod 640 "$LOG_FILE"
fi

# Comprovar directoris locals abans de fer el backup si falta algun d'aquests directoris acaba el programa i més passo codis d'error al figerl historic.log de cada cosa
echo "Comprovant carpetes..."
if [ ! -d /var/lib/etcd ]; then
    echo "Error: No existeix /var/lib/etcd" >&2
    echo "Error: No existeix /var/lib/etcd" >> "$LOG_FILE"
    exit 2
fi

if [ ! -d /etc/kubernetes ]; then
    echo "Error: No existeix /etc/kubernetes" >&2
    echo "Error: No existeix /etc/kubernetes" >> "$LOG_FILE"
    exit 3
fi

if [ ! -d /home/asix/odoo-kubernetes ]; then
    echo "Error: No existeix /home/asix/odoo-kubernetes" >&2
    echo "Error: No existeix /home/asix/odoo-kubernetes" >> "$LOG_FILE"
    exit 4
fi

# Ara creo l'arxiu de backup i el comprimeixo amb les carpetes necessaries
# Genero la data per el nom del fitxer de backup agafant (any, mes, dia, hora, minut i segon) pk no hi hagi cap igual
# Aquí separem dos casos, si s'executa l'script manualment o automàtic ja que si és automàtic no s'ha de fer la copia de la base de dades
if [ -n "$FROM_SETUP" ]; then
    echo "El backup s'executa després del setupKubernetes" >> "$LOG_FILE"
    FITXER="backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    sudo tar -czf "$FITXER" /var/lib/etcd /etc/kubernetes
else
    echo "El backup s'executa manualment" >> "$LOG_FILE"
    FITXER="backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    sudo tar -czf "$FITXER" /var/lib/etcd /etc/kubernetes /home/asix/odoo-kubernetes
fi

if [ $? -ne 0 ]; then
    echo "ERROR: La compressió ha fallat (codi d'error: $?)" >&2
    echo "ERROR: La compressió ha fallat (codi d'error: $?)" >> "$LOG_FILE"
    exit 5
fi

# Transfereixo el fitxer comprimit i l'envio amb scp a on haguem posat a la part de dalt del programa
scp -i "$CLAU_SSH" "$FITXER" "$USUARI_REMOT@$DESTI_IP:$DIRECTORI_REMOT"
if [ $? -ne 0 ]; then
    echo "ERROR: Fallida en el transferiment a $DESTI_IP (codi d'error: $?)" >&2
    echo "ERROR: Fallida en el transferiment a $DESTI_IP (codi d'error: $?)" >> "$LOG_FILE"
    exit 6
fi

# Finalment elimino els arxius locals de backup un cop la transferencia esta feta aixi no n'acumulem
rm "$FITXER"
if [ $? -ne 0 ]; then
    echo "ERROR: Error al borrar el backup local (codi d'error: $?)" >&2
    echo "ERROR: Error al borrar el backup local (codi d'error: $?)" >> "$LOG_FILE"
    exit 7
fi

# Aqui ha funcionat tot i ho guardo amb la data, i l'usuari
DATA=$(date "+%Y-%m-%d %H:%M:%S")
USUARI=$(whoami)
echo "[$DATA] Usuari: $USUARI - Backup '$FITXER' enviat correctament" >> "$LOG_FILE"
echo "Tot a funcionat correctament"
