# Setting up the stateless instance
This part will be really similar to the last one, but with some small things removed, so feel free to skip this part.
## Create the VM
Firstly, let's create the VM that will contain the php part of this workshop:
```PowerShell
az vm create --resource-group myResourceGroup --name myVM --image UbuntuLTS --admin-username azureuser --generate-ssh-keys
```

> Image chosen: <br>
> Canonical:UbuntuServer:18.04-LTS:18.04.202401161

## Open Port for Web
Next, we need to open the different ports of our VM:
```PowerShell
az vm open-port --port 80 --resource-group myResourceGroup --name myVM
```


## Deploy the app on the VM
### Connection to the VM
We will connect to the VM thanks to the ssh connection:
```PowerSHel
ssh azureuser@<public-ip-address>
```
The needed public ip address can be found here:
```PowerShell
az vm show --resource-group myResourceGroup --name myVM --show-details --query [publicIps] --output tsv
```
### Install dependancies
To be able to run PHP on the server, we need to install Apache:
```bash
sudo apt update
sudo apt install apache2 php libapache2-mod-php php-pgsql
```
### Make Apache launch itself upon turning the VM on
```bash
sudo systemctl enable apache2
```
### Upload the folder on the VM
Firstly, just zip it
```PowerShell
tar -czvf <folder>.tar.gz <destination>
```
Then, we upload it on the VM
```PowerShell
scp .\<app name>.tar.gz azureuser@<public ip>:/home/azureuser
```
On the VM, move the archived folder into /var/www/html, and unarchive it
```bash
sudo tar -xzvf <app>.tar.gz
```

## Configure Apache2
Now, the stateless side of the app is working fine. The problem is that you can only access it by http://<ip>/app/www.
And when you go to http://<ip>/, you only see the default page. now, we will remove this default page, and modify apache2's conf to access the website from http://<ip>/.
### Remove index.html
It is the initial file written by Apache2. It is useless, remove it.
After deleting it and accessing the website's root, you can see that you can access all the folder.
To remove it, modify Apache2's configuration file.
```bash
sudo nano /etc/apache2/apache2.conf 
```
Go to the part that looks like
```html
<Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
</Directory>
```

And change it to
```html
<Directory [new root]>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
        Allow from all
</Directory>
```

To finish this, reload apache2.
```bash
sudo systemctl reload apache2
```
Now, the website's root is forbidden to the user, but the website is still hosted on /app/www/.
To resolve this, go to /etc/apache2/sites-available/ modify the file named "000-default.conf".
In this file, replace "DocumentRoot /var/www/html" to "DocumentRoot [new Path]".

Reload apache2 once again
```bash
sudo systemctl reload apache2
```

And now, as you see, the main page in on the root of the website.