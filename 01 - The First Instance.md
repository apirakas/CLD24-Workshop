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
```bash
sudo apt update
sudo apt install -y apache2 php php-pgsql libapache2-mod-php postgresql postgresql-contrib
```

## postgreSQL Configuration
We connect to our postgresql server
```bash
sudo -i -u postgres
psql
```

To create the database that will be used by the application.
```SQL
CREATE DATABASE workshopcld;
CREATE USER first WITH ENCRYPTED PASSWORD 'caca';
GRANT ALL PRIVILEGES ON DATABASE workshopCLD TO first;
-- Create the different objects and insert data
\q
exit

```

## Deploy the app
To do this, we firstly need to archive the project
```bash
tar -czvf <folder>.tar.gz <destination>
```
Then, we upload it on the VM
```bash
scp .\<app name>.tar.gz azureuser@<public ip>:/home/azureuser
```
from our local machine, and then we connect again on the VM to move it to the path "/var/www/html".
we then adjust the folder's permissions:
```bash
sudo chmod -R 755 ./<app>
sudo chown -R www-data:www-data ./<app>
```
Then, we added a configuration file for the website:
```bash
sudo nano /etc/apache2/sites-available/app.conf
```
```html
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/app/www

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

We then activated the website and reloaded Apache:
```bash
sudo a2ensite app.conf
sudo systemctl restart apache2
```


## Secure the first app
The problem now, is that the website is available on http://<ip>/app/www. It means that connecting to http://<ip>/, we are in the root folder. So we can see everything, espacially download the init.sql file and see all the configuration.
This website helped us to resolve the problem:
https://gist.github.com/masudcsesust04/9e6e2b598e5eeab80dd80f2b5f54c1f1



using ufw to allow only useful trafic
```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Apache Full'
sudo ufw enable
```

## Setting up HTTPS
Here, we use "Let's Encrypt" to get a free SSL certificate and secure the connections.

```bash
sudo apt-get install certbot python3-certbot-apache
sudo certbot --apache

```
