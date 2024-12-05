#!/bin/sh

# Comprova que s'han passat els arguments correctes
if [ $# -ne 2 ]; then
  echo "Ús: $0 mida_en_KB fitxer"
  exit 1
fi

# Assigna els paràmetres a variables
MIDA_KB=$1
FITXER=$2
USUARI=$(whoami)
DATA_HORA=$(date "+%Y-%m-%d %H:%M:%S")
LOG_FILE="/var/log/massaGran.log"

# Comprova si el fitxer existeix
if [ ! -f "$FITXER" ]; then
  echo "$DATA_HORA - Usuari: $USUARI - ERROR: El fitxer $FITXER no existeix." | tee -a $LOG_FILE
  exit 1
fi

# Calcula la mida del fitxer en KB
MIDA_FITXER=$(du -b "$FITXER" | cut -f1)

# Comprova si la mida del fitxer és més gran que la mida donada
if [ "$MIDA_FITXER" -gt "$MIDA_KB" ]; then
  DIFERENCIA=$(($MIDA_FITXER - $MIDA_KB))
  echo "$DATA_HORA - Usuari: $USUARI - INFO: El fitxer $FITXER és més gran que $MIDA_KB KB per $DIFERENCIA KB." | tee -a $LOG_FILE
fi



