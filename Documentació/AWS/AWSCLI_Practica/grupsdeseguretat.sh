#!/bin/sh

# Crear grup de seguretat
aws ec2 create-security-group --group-name lluc-sg --description "Grup de Seguretat per a Hackathon"

# Guardar ID del grup de seguretat, ho faig per després assignar aquesta ID a la màquina
ID=$(aws ec2 describe-security-groups --filter Name=group-name,Values="lluc-sg" --query 'SecurityGroups[0].[GroupId]' --output text)

# Comprovar si hi ha hagut algun error al crear el grup perquè sino no funcionara res
if [ $? -ne 0 ]; then
    echo "Error creant el grup de seguretat"
    exit 2
fi

#Aquí he obert els ports  necessaris per tota la infraestructura
# SSH
aws ec2 authorize-security-group-ingress --group-id $ID --protocol tcp --port 22 --cidr 0.0.0.0/0
# RDP
aws ec2 authorize-security-group-ingress --group-id $ID --protocol tcp --port 3389 --cidr 0.0.0.0/0
# HTTP
aws ec2 authorize-security-group-ingress --group-id $ID --protocol tcp --port 80 --cidr 0.0.0.0/0
# HTTPS
aws ec2 authorize-security-group-ingress --group-id $ID --protocol tcp --port 443 --cidr 0.0.0.0/0
# DNS (UDP)
aws ec2 authorize-security-group-ingress --group-id $ID --protocol udp --port 53 --cidr 0.0.0.0/0
# DNS (TCP)
aws ec2 authorize-security-group-ingress --group-id $ID --protocol tcp --port 53 --cidr 0.0.0.0/0
# LDAP
aws ec2 authorize-security-group-ingress --group-id $ID --protocol tcp --port 389 --cidr 0.0.0.0/0
# Secure LDAP
aws ec2 authorize-security-group-ingress --group-id $ID --protocol tcp --port 636 --cidr 0.0.0.0/0

echo "Grup de seguretat creat amb ID: $ID"

