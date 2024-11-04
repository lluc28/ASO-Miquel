#!/bin/sh

# Comprova que s'han passat els arguments correctes
if [ $# -ne 2 ]; then
  echo "Ús: $0 mida_en_KB directori"
  exit 1
fi

# Assigna els paràmetres a variables
MIDA_KB=$1
DIRECTORI=$2
USUARI=$(whoami)
DATA_HORA=$(date "+%Y-%m-%d %H:%M:%S")
LOG_FILE="/var/log/massaGranDirectori.log"

# Comprova si el directori existeix
if [ ! -d "$DIRECTORI" ]; then
  echo "$DATA_HORA - Usuari: $USUARI - ERROR: El directori $DIRECTORI no existeix." | tee -a $LOG_FILE
  exit 1
fi

# Calcula la mida total del directori en KB
MIDA_DIRECTORI=$(du -s -k "$DIRECTORI" | cut -f1)

# Comprova si la mida del directori és més gran que la mida donada
if [ "$MIDA_DIRECTORI" -gt "$MIDA_KB" ]; then
  DIFERENCIA=$(($MIDA_DIRECTORI - $MIDA_KB))
  echo "$DATA_HORA - Usuari: $USUARI - INFO: El directori $DIRECTORI és més gran que $MIDA_KB KB per $DIFERENCIA KB." | tee -a $LOG_FILE
else
  echo "$DATA_HORA - Usuari: $USUARI - INFO: El directori $DIRECTORI no supera els $MIDA_KB KB." | tee -a $LOG_FILE
fi
