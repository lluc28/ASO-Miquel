#!/bin/bash

# Aquesta és l'operació que volem fer (100*cputime)/(etime) que és igual al percentatge ús de la cpu
PID=$1

DADES=$(ps -p $PID -o cputime=,etime=)

CPUTIME=$(echo "$DADES" | cut -d ' ' -f 1)
ETIME=$(echo "$DADES" | cut -d ' ' -f 2)

CPUTIME_SEC=$(echo $CPUTIME | cut -d ':' --output-delimiter=' ' -f 1,2,3 | { read h m s; echo $((10#$h*3600 + 10#$m*60 + 10#$s)); })
ETIME_SEC=$(echo $ETIME | cut -d ':' --output-delimiter=' ' -f 1,2,3 | { read h m s; echo $((10#$h*3600 + 10#$m*60 + 10#$s)); })

CPU_PERCENT=$(( 100 * CPUTIME_SEC / ETIME_SEC ))

echo "$CPU_PERCENT% de CPU utilitzat pel procés amb PID $PID"
