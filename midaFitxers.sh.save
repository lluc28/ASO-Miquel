#!/bin/sh

# Comprova que s'han passat els arguments correctes
if [ $# -lt 2 ]; then
  echo "Ús: $0 mida_en_KB fitxer1 fitxer2 ... fitxerN"
  exit 1
fi

# Assigna la mida a una variable
MIDA_KB=$1
shift # Elimina el primer argument (mida) per treballar amb els fitxers

USUARI=$(whoami)
DATA_HORA=$(date "+%Y-%m-%d %H:%M:%S")
LOG_FILE="/var/log/massaGran.log"

# Recorre cada fitxer passat com argument
for FITXER in "$@"; do
  # Comprova si el fitxer existeix
  if [ ! -f "$FITXER" ]; then
    echo "$DATA_HORA - Usuari: $USUARI - ERROR: El fitxer $FITXER no existeix." | tee -a $LOG_FILE
    continue # Continua amb el següent fitxer
  fi
