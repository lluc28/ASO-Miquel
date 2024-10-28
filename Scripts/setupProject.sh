#!/bin/sh

# Comprovem que hi hagi entre 2 i 3 arguments
if [ $# -ne 2 ] && [ $# -ne 3 ]; then
    echo " Usage: nomPrograma Empresa Projecte Path(opcional) "
    echo " Usage: nomPrograma Empresa Projecte Path(opcional) " >> /var/log/errorsProjectes/output.log
    exit 1 # codi d'error per paràmetres incorrectes
fi

# Si hi ha un tercer paràmetre, fem servir el directori passat, sinó fem servir './'
if [ $# -eq 3 ]; then
    DIRECTORI_BASE=$3
else
    DIRECTORI_BASE="./"
fi

# Comprovem si la carpeta ja existeix
if [ -d "$DIRECTORI_BASE/$1/$2" ]; then
    echo " La carpeta '$2' de l'empresa '$1' ja existeix al directori '$DIRECTORI_BASE'"
    echo " La carpeta '$2' de l'empresa '$1' ja existeix al directori '$DIRECTORI_BASE'" >> /var/log/errorsProjectes/output.log
    exit 2 # codi d'error perquè la carpeta ja existeix
fi

# Creem les carpetes si no existeixen
mkdir -p "$DIRECTORI_BASE/$1/$2/codi"
mkdir -p "$DIRECTORI_BASE/$1/$2/documentació/legal"
mkdir -p "$DIRECTORI_BASE/$1/$2/documentació/manuals"

# Obtenim la data actual i l'usuari que ha executat l'script
DATA=$(date "+%Y-%m-%d %H:%M:%S")
USUARI=$(whoami)

# Missatge de confirmació
echo "Ets un crack, has sapigut executar l'script correctament, congrats!"

# Guardem un registre tant a /var/log com a la carpeta creada
echo "[$DATA] Usuari: $USUARI - Creada carpeta '$2' de l'empresa '$1' a '$DIRECTORI_BASE'" >> /var/log/projectes/output.log
echo "[$DATA] Usuari: $USUARI - Creada carpeta '$2' de l'empresa '$1' a '$DIRECTORI_BASE'" >> "$DIRECTORI_BASE/$1/$2/project_creation.log"

