#!/bin/bash

# Seleccionar AMI basat en el tipus
case $TYPE in
  "WS") AMI="ami-0fe0e5689ec061c97" ;;  # Windows Server
  "Debian") AMI="ami-064519b8c76274859" ;;  # Debian
  *) 
    echo "Error: El Tipus d'instància no és vàlid."
    exit 1
  ;;
esac

# Crear instància EC2
ID=$(aws ec2 run-instances \
  --image-id "$AMI" \
  --key-name "vockey" \
  --instance-type "t2.micro" \
  --network-interfaces '{"AssociatePublicIpAddress":true,"DeviceIndex":0,"Groups":["'"$SG_ID"'"]}' \
  --credit-specification '{"CpuCredits":"standard"}' \
  --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"'"$TYPE"'"}]}' \
  --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":true,"EnableResourceNameDnsAAAARecord":false}' \
  --count "1" \
  --query 'Instances[0].InstanceId' \
  --output text)

# Validació de la creació de la instància
if [ -z "$ID" ]; then
  echo "Error: No s'ha pogut crear la instància $TYPE."
  exit 2
fi

echo "Instància $TYPE creada amb ID: $ID"
