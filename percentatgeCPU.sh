#!/bin/bash

# Aquesta és l'operació que volem fer (100*cputime)/(etime) que és igual al percentatge ús de la cpu
PID=$1
DADES=$(ps -p $PID pid=,cputime=cputime,etime=etime)
 
