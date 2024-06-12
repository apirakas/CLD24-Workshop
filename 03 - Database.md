# Create the database
On this part we will create a separate database
## Create the network subnet
This command sequence uses the Azure CLI to create a new subnet within an existing virtual network on Azure, specifically designed for a PostgreSQL database environment. The script sets the subnet name, associates it with a predefined resource group and virtual network, and specifies the address range for the subnet. This setup ensure that resources like databases are isolated and secure within dedicated subnets.
```PowerShell
[INPUT]
az network vnet subnet create `
      --name 'NewSubnetForPostgreSQL' `
      --resource-group 'CLDWorkshop' `
      --vnet-name 'StatelessInstanceVNET' `
      --address-prefixes '10.0.2.0/24'

[OUTPUT]
{
  "addressPrefix": "10.0.2.0/24",
  "delegations": [],
  "etag": "W/\"ef1ffd0b-b836-40cc-a1b0-7bac3a2bd12f\"",
  "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/virtualNetworks/StatelessInstanceVNET/subnets/NewSubnetForPostgreSQL",
  "name": "NewSubnetForPostgreSQL",
  "privateEndpointNetworkPolicies": "Disabled",
  "privateLinkServiceNetworkPolicies": "Enabled",
  "provisioningState": "Succeeded",
  "resourceGroup": "CLDWorkshop",
  "type": "Microsoft.Network/virtualNetworks/subnets"
}

```

## Creating a PostgreSQL Flexible Server on Azure
The provided script commands the Azure CLI to create a new PostgreSQL Flexible Server instance in the Azure cloud. This involves specifying configurations such as server name, resource group, location, and network settings. The script checks for the existence of necessary resources like the resource group and network settings, then proceeds to set up the server with specific parameters including the PostgreSQL version, server tier, and storage size. 
```PowerShell
[INPUT]
az postgres flexible-server create `
  --name 'cld-workshop-db' `
  --resource-group 'CLDWorkshop' `
  --location 'switzerlandnorth' `
  --admin-user 'postgres' `
  --admin-password '***' `
  --version '16' `
  --tier 'Burstable' `
  --sku-name 'Standard_B1ms' `
  --vnet 'StatelessInstanceVNET' `
  --subnet 'NewSubnetForPostgreSQL' `
  --storage-size '32'
  
[OUTPUT]
Checking the existence of the resource group 'CLDWorkshop'...
Resource group 'CLDWorkshop' exists ? : True 
You have supplied a Vnet and Subnet name. Verifying its existence...
Using existing Vnet "StatelessInstanceVNET" in resource group "CLDWorkshop"
Using existing Subnet "NewSubnetForPostgreSQL" in resource group "CLDWorkshop"
Do you want to create a new private DNS zone cld-workshop-db.private.postgres.database.azure.com in resource group CLDWorkshop (y/n): y
Creating a private dns zone cld-workshop-db.private.postgres.database.azure.com in resource group "CLDWorkshop"
Creating PostgreSQL Server 'cld-workshop-db' in group 'CLDWorkshop'...
Your server 'cld-workshop-db' is using sku 'Standard_B1ms' (Paid Tier). Please refer to https://aka.ms/postgres-pricing for pricing details
Creating PostgreSQL database 'flexibleserverdb'...
Make a note of your password. If you forget, you would have to reset your password with "az postgres flexible-server update -n cld-workshop-db -g CLDWorkshop -p <new-password>".
Try using 'az postgres flexible-server connect' command to test out connection.
{
  "connectionString": "postgresql://postgres:***@cld-workshop-db.postgres.database.azure.com/flexibleserverdb?sslmode=require",
  "databaseName": "flexibleserverdb",
  "host": "cld-workshop-db.postgres.database.azure.com",
  "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.DBforPostgreSQL/flexibleServers/cld-workshop-db",
  "location": "Switzerland North",
  "password": "***",
  "resourceGroup": "CLDWorkshop",
  "skuname": "Standard_B1ms",
  "subnetId": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/virtualNetworks/StatelessInstanceVNET/subnets/NewSubnetForPostgreSQL",
  "username": "postgres",
  "version": "16"
}
```

**To remember**

In Azure, the sku-name specifies the performance and pricing tier of database services. Key tiers include:

> Basic: For light workloads with minimal processing requirements.
> Standard: Suitable for many production applications, offering a balance of performance and cost.
> Premium: Provides high performance for demanding applications, with fast I/O and robust capabilities.
> General Purpose: Good for most business workloads, offering a balance of compute, memory, and I/O.
> Memory Optimized: For applications that require high memory performance.
> Business Critical: Offers top resilience and performance for critical systems.
> Hyperscale: For extremely large databases or applications requiring massive scale.

Billing for Azure databases primarily depends on several key aspects:

> Pricing Tier: Includes different levels like Basic, Standard, Premium, General Purpose, Memory Optimized, and Business Critical. Higher tiers generally cost more due to better performance and more features.
> Compute and Storage: Charges are based on the compute resources (measured in vCores or DTUs - Database Transaction Units) and the amount of storage utilized.
> Backup Storage: There may be extra charges for backup storage that goes beyond the included allotment, which is calculated based on backup size.
> Data Transfer: Costs are incurred mainly for outbound data transfers (egress) from Azure data centers.

## Configuring database

Now that we've created the database, we need to populate it. To do this, we need to run the following commands from an instance on the same network as the database.

```sh
psql -h cld-workshop-db.postgres.database.azure.com -p 5432 -U postgres
# CREATE DATABASE workshopcld;
# \q
```

Create entry on the DB

```sh
psql -h cld-workshop-db.postgres.database.azure.com -p 5432 -U postgres -d workshopcld -f /var/www/html/app/postgres/init.sql
```

## Modify connexion parameters on instance

``` sh
vi /var/www/html/app/www/dbConnect.php
-----------------------------------------
$host = 'cld-workshop-db.postgres.database.azure.com'; // utiliser le nom dns 
$port = '5432'; // Le port par défaut pour PostgreSQL
$dbname = 'workshopcld'; // Le nom de la base de données
$user = 'postgres'; // Le username
$password = '***'; // Le mot de passe
```

