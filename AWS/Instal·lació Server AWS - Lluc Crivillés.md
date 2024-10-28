## Instal·lació i preparació del Windows Server 2022

#  Codi vista prèvia

aws ec2 run-instances --image-id "ami-05f283f34603d6aed" --instance-type "t2.micro" --key-name "vockey" --network-interfaces '{"AssociatePublicIpAddress":true,"DeviceIndex":0,"Groups":["sg-07b4ff9fb8518af64"]}' --credit-specification '{"CpuCredits":"standard"}' --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"WindowsServerLluc(Miquel)"}]}' --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"required"}' --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":true,"EnableResourceNameDnsAAAARecord":false}' --count "1" 

# Firewall

## Descarregar el PEM 
![image](https://github.com/user-attachments/assets/6eaca239-c4a0-4911-b5b9-b4b0848afc5b)

## Passos per conectar-se per RDP
![image](https://github.com/user-attachments/assets/670672a6-c8ff-4b4c-b235-2ba1bc35ed5c)
![image](https://github.com/user-attachments/assets/b84d5c56-f540-492b-af93-e0df46e42723)
![image](https://github.com/user-attachments/assets/a3e0c300-d381-493f-85e5-6ea299835087)

Pujar la clau PEM que he descarregat abans:
![image](https://github.com/user-attachments/assets/ad44af18-a366-4022-9f25-ad642b406f00)
![image](https://github.com/user-attachments/assets/68e1f758-b4f7-4f42-b58b-8d0e00a0758b)
![image](https://github.com/user-attachments/assets/17238b06-801f-480d-b123-59c893c72f7a)

Decarregar el fitxer remot i copiar la contrasenya:
![image](https://github.com/user-attachments/assets/c4bb0fac-0d4d-474e-a269-8d7cd7970471)

Obrir el fitxer RDP:
![image](https://github.com/user-attachments/assets/7e57b562-1eb5-45cb-b840-7a879c09f3e7)



