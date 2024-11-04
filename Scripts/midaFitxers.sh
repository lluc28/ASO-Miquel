#!/bin/sh

# Reviso que hi hagin dos arguments
if [ $# -lt 2 ]; then
  echo "Ús: $0 mida_en_KB fitxer1 fitxer2 ... fitxerN"
  exit 1
fi

# El primer argument és la mida en KB
MIDA_KB=$1

# Variables per al log
USUARI=$(whoami)
DATA_HORA=$(date "+%Y-%m-%d %H:%M:%S")
LOG_FILE="/var/log/massaGran.log"

# Recorro els arguments, començant pel segon
for i in $(seq 2 $#); do
  FITXER=${!i} # Agafo el valor de l'argument que correspon al número i del bucle for

  # REviso que el fitxer existeix
  if [ ! -f "$FITXER" ]; then
    echo "$DATA_HORA - Usuari: $USUARI - ERROR: El fitxer $FITXER no existeix." | tee -a $LOG_FILE
    continue
  fi

  # amb la comanda du calculo l'espai que ocupa el fitxer
  MIDA_FITXER=$(du -k "$FITXER" | cut -f1)

  # Aquí resto donada (MIDA_KB) de la mida del fitxer (MIDA_FITXER) i faig una cosa o un altre depenent del resultat
  if [ "$MIDA_FITXER" -gt "$MIDA_KB" ]; then
    DIFERENCIA=$(($MIDA_FITXER - $MIDA_KB))
    echo "$DATA_HORA - Usuari: $USUARI - INFO: El fitxer $FITXER és més gran que $MIDA_KB KB per $DIFERENCIA KB." | tee -a $LOG_FILE
  else
    echo "$DATA_HORA - Usuari: $USUARI - INFO: El fitxer $FITXER no supera els $MIDA_KB KB." | tee -a $LOG_FILE
  fi
done
