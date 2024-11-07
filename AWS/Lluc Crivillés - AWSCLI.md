# AWS CLI en Debian

## Instal·lació
1. Actualitzar el sistema
   
sudo apt update && sudo apt upgrade -y

![image](https://github.com/user-attachments/assets/e1d523c4-608d-48e3-8913-233c34f0baa4)

2. Descarregar l’Instal·lador d’AWS CLI, Descomprimir el fitxer descarregat i Instal·lar el fitxer desconegut

$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

![image](https://github.com/user-attachments/assets/0cee7f8e-4cd9-4e55-a44c-de49df1572fa)

3. Verificar la Instal·lació

aws --version

![image](https://github.com/user-attachments/assets/6002a099-849a-4bff-b44a-b2d4fa1b2ba8)


## Configuració

1. Crear una carpeta al debian

![image](https://github.com/user-attachments/assets/8de5fc52-4501-46e9-9e13-822d87fa6273)

2. Crear un fitxer credentials

![image](https://github.com/user-attachments/assets/d909b0b5-d0da-418a-9193-7fdf713d6c3e)

3. Afegir la línia d'AWS CLI

Primer he copiat la línia de l'AWS

![image](https://github.com/user-attachments/assets/4b303090-a60f-474c-8eb2-32a36d1f7bb8)

Finalment l'he enganxat al fitxer credentials

![image](https://github.com/user-attachments/assets/40dbe9cd-6762-4f4e-a263-bfb8dbe80c1d)


