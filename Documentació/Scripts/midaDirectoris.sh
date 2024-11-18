#!/bin/sh

# Comprovo que s'han passat almenys dos arguments: mida i directoris.
if [ $# -lt 2 ]; then
  echo "Ús: $0 mida_en_KB directori1 directori2 ... directoriN"
  exit 1
fi

# Assigno la mida en KB al primer argument.
MIDA_KB=$1
USUARI=$(whoami)
DATA_HORA=$(date "+%Y-%m-%d %H:%M:%S")
LOG_FILE="/var/log/massaGranDirectori.log"

# Recorro cada directori a partir del segon argument.
for i in $(seq 2 $#); do
  DIRECTORI=${!i} # Obtenim el nom del directori

  # Comprovo si el directori existeix.
  if [ ! -d "$DIRECTORI" ]; then
    echo "$DATA_HORA - Usuari: $USUARI - ERROR: El directori $DIRECTORI no existeix." | tee -a $LOG_FILE
    continue # Continuo amb el següent directori.
  fi

  # Calculo la mida total del directori en KB.
  MIDA_DIRECTORI=$(du -s -k "$DIRECTORI" | cut -f1)

  # Comprovo si la mida del directori supera la mida donada.
  if [ "$MIDA_DIRECTORI" -gt "$MIDA_KB" ]; then
    DIFERENCIA=$(($MIDA_DIRECTORI - $MIDA_KB))
    echo "$DATA_HORA - Usuari: $USUARI - INFO: El directori $DIRECTORI és més gran que $MIDA_KB KB per $DIFERENCIA KB." | tee -a $LOG_FILE
  else
    echo "$DATA_HORA - Usuari: $USUARI - INFO: El directori $DIRECTORI no supera els $MIDA_KB KB." | tee -a $LOG_FILE
  fi
done
