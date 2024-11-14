#!/bin/bash

# Nom del grup de seguretat
NOM_GRUP="grup_seguretat_lluc"

# Comprovar si el grup ja existeix
if grep -q "^$NOM_GRUP:" /etc/group; then
    echo "El grup $NOM_GRUP ja existeix."
else
    # Crear el grup
    sudo groupadd $NOM_GRUP
    echo "Grup $NOM_GRUP creat correctament."
fi

# Demanar els noms dels usuaris a afegir al grup (separats per espais)
read -p "Introdueix els noms dels usuaris a afegir al grup (separats per espais): " USUARIS

# Afegir cada usuari al grup
for USUARI in $USUARIS; do
    # Comprovar si l'usuari existeix
    if id "$USUARI" &>/dev/null; then
        # Afegir l'usuari al grup
        sudo usermod -a -G $NOM_GRUP $USUARI
        echo "Usuari $USUARI afegit al grup $NOM_GRUP."
    else
        echo "L'usuari $USUARI no existeix."
    fi
done

# Demanar el directori sobre el qual assignar permisos
read -p "Introdueix el directori al qual assignar permisos: " DIRECTORI

# Comprovar si el directori existeix
if [ -d "$DIRECTORI" ]; then
    # Canviar el grup del directori al nou grup de seguretat
    sudo chgrp -R $NOM_GRUP $DIRECTORI
    echo "Grup de $NOM_GRUP assignat al directori $DIRECTORI."

    # Establir permisos (lectura, escriptura i execució per al grup)
    sudo chmod -R 770 $DIRECTORI
    echo "Permisos assignats al grup $NOM_GRUP en el directori $DIRECTORI."
else
    echo "El directori $DIRECTORI no existeix."
fi

echo "Gestió de grups de seguretat completada!"
