# Creation of a first instance, stateful.

## Creation of the resource Group
Firstly, to create an instance, we must create a Resource Group, A resource Group is used to manage all the resources as a "coherent set". It makes life easier for Resources management, deployments privileges management, etc.<br>
Here is the command to create one:
```PowerShell
az group create --name <name of the RG> --location <location>

```
The location we chose is "switzerlandnorth".
```JSON
{
  "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop",
  "location": "switzerlandnorth",
  "managedBy": null,
  "name": "CLDWorkshop",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```
After that, it will be possible to create a VM.
## Create a Virtual Machine
Now that the RG is created, it will be possible to make something less "abstract".
Create the VM:
```PowerShell
az vm create --resource-group myResourceGroup --name myVM --image UbuntuLTS --admin-username azureuser --generate-ssh-keys
```
Note that it is possible to see the image list:
```PowerShell
az vm image list
```
Command done:
```PowerShell
az vm create --resource-group CLDWorkshop --name StatefulInstance --image "Canonical:UbuntuServer:18.04-LTS:18.04.202401161" --admin-username azureuser --generate-ssh-keys
```

## Open Ports for Web and PostgreSQL
Next, we need to open the different ports of our VM:
```PowerShell
az vm open-port --port 80 --resource-group myResourceGroup --name myVM
az vm open-port --port 5432 --priority 1001 --resource-group myResourceGroup --name myVM
```

## Connection to the VM
We will connect to a Vm thanks to a ssh connection:
```PowerSHel
ssh azureuser@<public-ip-address>
```
The needed public ip address can be found here:
```PowerShell
az vm show --resource-group myResourceGroup --name myVM --show-details --query [publicIps] --output tsv
```
## Installation of the Web, PHP and PostgreSQL Server
Since we are now connected, it is possible to install everything needed:
```PowerShell
sudo apt update
sudo apt install -y apache2 php php-pgsql libapache2-mod-php postgresql postgresql-contrib
```

## postgreSQL Configuration
We connect to our postgresql server
```PowerShell
sudo -i -u postgres
psql
```

To create the database that will be used by the application.
```PowerShell
CREATE DATABASE workshopCLD;
CREATE USER first WITH ENCRYPTED PASSWORD 'caca';
GRANT ALL PRIVILEGES ON DATABASE workshopCLD TO first;
\q
exit

```