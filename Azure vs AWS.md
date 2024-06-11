# Différences entre Azure et AWS
### CLI
They have the same basic structure
#### Azure
```bash
az <service> <action>
```
#### AWS
```bash
aws <service> <action>
```
### Steps to create one instance
#### Azure
You first need a Resource group, then you can create a new instance ! The key-pair will be created alongside it
```js
// Resource Group creation
az group create --name <name of the RG> --location <location>

// Instance creation
az vm create --resource-group myResourceGroup --name myVM --image UbuntuLTS --admin-username azureuser --generate-ssh-keys

// To open ports
az vm open-port --port 80 --resource-group myResourceGroup --name myVM
az vm open-port --port 5432 --priority 1001 --resource-group myResourceGroup --name myVM
```
#### AWS
AWS requires a bit more work to get a simple instance running.
You will need a VPC, then a subnet, then a security group, open some ports, a key-pair and then can you create an instance !
```js
// Create a VPC
aws ec2 create-vpc --cidr-block <ip>

// Create a subnet
aws ec2 create-subnet --vpc-id vpc-xxxxxxxx --cidr-block <ip>

// Create a SG
aws ec2 create-security-group --group-name my-security-group --description "My security group" --vpc-id vpc-xxxxxxxx

// Then allow ports on the SG
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxx --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxx --protocol tcp --port 80 --cidr 0.0.0.0/0

// You will then need a key-pair
aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem
chmod 400 MyKeyPair.pem

// You can now create your instance
aws ec2 run-instances --image-id ami-0xxxxxxxxxxxxxx --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids sg-xxxxxxxx --subnet-id subnet-xxxxxxxx --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=myVM}]'
```

### Difference 
As we can see, Azure requires less steps to create a running instance while AWS requires more configuration to be done.
This is because Azure automatically creates required components, such as a subnet, when creating a new instance.

Azure is more "simplified", letting you quickly and easily get to create your instance. While AWS makes you create each component one at a time. However, it gives you way more control and freedom over how they are configured.

## Resource Group
Azure uses a Resource Group (RG) which is something AWS lacks. It is used to organize and manage resources deployed in Azure.

This provides logical grouping for easier management and resource organization. It is easily seen when creating new instances:you only need to provide the resource group in which the VM will be created for it to be added to said group.

Now this instance will be managed by this RG, which on a larger scale, will make it much easier to manage alongside other instances inside the same resource group

## AWS VPC vs Azure Virtual Network
Nothing much to say here, they have the same concept : both are used to define and manage the network environment.