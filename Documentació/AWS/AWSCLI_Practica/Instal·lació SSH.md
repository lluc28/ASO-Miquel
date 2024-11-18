## Instal·lació i preparació del SSH Windows Server

# Instal·lació SSH
![image](https://github.com/user-attachments/assets/fe9fddaf-c3b1-4f4b-b10d-fed86d3576e4)

## Activar l'SSH per defecte i mirar l'estat
![image](https://github.com/user-attachments/assets/6a3b8b17-7ee4-4274-9d1b-d355b0f9fc7d)

## Iniciar automàticament el servei del servidor SSH
![image](https://github.com/user-attachments/assets/e1609683-0e11-43b9-9584-6794b376dca7)

## Personalitzar el tallafoc
![image](https://github.com/user-attachments/assets/f6802955-b9a9-4b6c-ad48-4cfaeaf332aa)

## Preparar un usuari per poder-me connectar
![image](https://github.com/user-attachments/assets/43810aff-d490-4d2f-89e5-1f4bafdaf07b)

## Crear la carpeta per emmagatzemar les claus SSH
![image](https://github.com/user-attachments/assets/b9fbd529-3b69-44a8-85e0-3c63e3e65bb4)

## Afegir les claus i modificar els permisos de ".ssh" i "authorized_keys"
```powershell
Set-Content -Path $env:USERPROFILE\.ssh_keys\authorized_keys -Value "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOVW8UbxENFatfzs1r6wN1+B56keMitZ72z+5sVf/8hcd8fe+EsshZhFJOC3a3N61/prje/gWwo+bjmY6ZzCGDp7bwZ9XIveYQuA3ALs063Y91dqnz277m4bNmNCzqVx84YRvYC5+LSUktXMrXM2xIa8iUi6szY4ZeUO8K1e1i89Ke8KgajbjrwVFqretw+pZj/xD+pjTov2oQIv7a5QbGp0lUVjhzDUdsDxidXepvTVjyoJCbiSncbFAp2VEK4SkFU5TNxQWcbEXCbjROUupR4yXz7Z4Onlj0XJ25I48hN7KxKeHg5+9PwV0b3PBZ2Ks/WyYjEXSH1YdMXsL6MHHb lluc@debian"

Set-Content -Path C:\ProgramData\ssh\administrators_authorized_keys -Value "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOVW8UbxENFatfzs1r6wN1+B56keMitZ72z+5sVf/8hcd8fe+EsshZhFJOC3a3N61/prje/gWwo+bjmY6ZzCGDp7bwZ9XIveYQuA3ALs063Y91dqnz277m4bNmNCzqVx84YRvYC5+LSUktXMrXM2xIa8iUi6szY4ZeUO8K1e1i89Ke8KgajbjrwVFqretw+pZj/xD+pjTov2oQIv7a5QbGp0lUVjhzDUdsDxidXepvTVjyoJCbiSncbFAp2VEK4SkFU5TNxQWcbEXCbjROUupR4yXz7Z4Onlj0XJ25I48hN7KxKeHg5+9PwV0b3PBZ2Ks/WyYjEXSH1YdMXsL6MHHb lluc@debian"

icacls $env:USERPROFILE\.ssh_keys /inheritance:r
icacls $env:USERPROFILE\.ssh_keys /grant "$($env:USERNAME):(OI)(CI)F"
icacls $env:USERPROFILE\.ssh_keys\authorized_keys /grant "$($env:USERNAME):F"
```

## Anar al fitxer "C:\ProgramData\ssh\sshd_config" i descomentar aquestes línies:
```powershell
PubkeyAuthentication yes
PasswordAuthentication no
```

## Reiniciar el servei SSH
```powershell
Restart-Service sshd
```

## Canviar hostname i reiniciar servidor
```powershell
Rename-Computer -NewName "WSLluc" -Restart
```

##  Configurar el domini

## Instalar AD
```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
```

## Posar el servidor com a Controlador de Domini
```powershell
Install-ADDSForest -DomainName "lluc.local" -DomainNetbiosName "WindowsServer22" -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "Patata123." -Force) -InstallDns -Force
```

##Script creació màquina debian
```powershell
aws ec2 run-instances --image-id "ami-064519b8c76274859" --instance-type "t2.micro" --key-name "vockey" --network-interfaces '{"AssociatePublicIpAddress":true,"DeviceIndex":0,"Groups":["sg-05780de635f235ada"]}' --credit-specification '{"CpuCredits":"standard"}' --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"DebianLluc"}]}' --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"required"}' --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":true,"EnableResourceNameDnsAAAARecord":false}' --count "1"
```
