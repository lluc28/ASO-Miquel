# Hackaton Script Lluc

## Requisits per executar l'script
1. Anar a ~/.aws/credentials i posar la clau que surt a AWS Details (Accedeix a AWS i crea una nova clau d'accés des del panell de control de l'AWS IAM).
   

## Execució
1. Definir els arguments d'execució
L'script desplegar_Infraestructura.sh necessita tres arguments per executar:

  -d <Domain Name>: El nom del domini AD.
  -c <Client Number>: Nombre de clients que vols crear (ha de ser entre 1 i 10).
  -u <User1/Pass1,User2/Pass2,...>: Llista d'usuaris i contrasenyes per als clients en format Usuari/Contrasenya separats per comes.

  
2. Exemple d'execució

Un cop hagis configurat les teves credencials i tinguis els fitxers necessaris, pots executar l'script com segueix:

    ./desplegar_Infraestructura.sh -d "example.local" -c 3 -u "user1/pass1,user2/pass2"


3. Explicació dels paràmetres

    -d "example.local": Defineix el nom del domini AD.
    -c 3: Crea 3 clients.
    -u "user1/pass1,user2/pass2": Crea dos usuaris, "user1" amb contrasenya "pass1" i "user2" amb contrasenya "pass2".
