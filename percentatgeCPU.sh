#!/bin/bash

# Aquesta és l'operació que volem fer (100*cputime)/(etime) que és igual al percentatge ús de la cpu
PID=$1
DADES=$(ps -p $PID -o cputime=,etime=)

CPUTIME = cut -d 1
ETIME = cut -d 2
