# Kubernetes - Minibuke

## Preparar una màquina virtual Debian
Per tal de poder fer el Minibuke es necessita una màquina virutal amb 20GB lliures a la ruta /var:
![image](https://github.com/user-attachments/assets/11b62509-44b5-4d97-924e-5cda73a6fc7e)

## Passso que he seguit
1. Actualitzar el sistema
   
$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
$ sudo dpkg -i minikube_latest_amd64.deb


2. Cluster

$ minikube start


3. Interactuar amb el cluster

$ kubectl get po -A


4. Desplegar aplicacions

