# The Auto Scaler

The auto scaler is to scale an app's stateless instance up or down, depending on the demand.
There a 3 types of auto scalers on Azure.

## Auto scaler types

1. **The manual scaling** allows us, as the name says, to scale the app manually, until the number of instances we want is up.<br>
command:

```PowerShell
Update-AzVmss -SkuCapacity <number of instances> -ResourceGroupName <resource group name> -VMScaleSetName <scale set name> 
```

2. **The autoscale** will scale the app automatically, depending on the rules we created. The rules are a meric's threshold that should not be exceeded. <br>
The available metrics are:
    * Percentage CPU
    * Network In
    * Network Out
    * Disk Read Bytes
    * Disk Write Bytes
    * Disk Read Operations/Sec
    * Disk Write Operations/Sec
    * CPU Credits Remaining
    * CPU Credits Consumed<br>

    Furthermore, you can set several rules that won't be the trigger's condition, but the behavior you want when the condition is met.
    Such as: <br>
    | scale operation | use case |
    |-----------------|----------|
    | Increase count by | A fixed number of VM instances to create. Useful in scale sets with a smaller number of VMs. |
    |Increase percent by| A percentage-based increase of VM instances. Good for larger scale sets where a fixed increase may not noticeably improve performance.|
    |Increase count to|Create as many VM instances are required to reach a desired maximum amount.|
    |Decrease count by|A fixed number of VM instances to remove. Useful in scale sets with a smaller number of VMs.|
    |Decrease percent by|A percentage-based decrease of VM instances. Good for larger scale sets where a fixed decrease may not noticeably reduce resource consumption and costs.|
    |Decrease count to|Remove as many VM instances are required to reach a desired minimum amount.|

3. **The scheduled autoscale** is similar to the auto scale, but the rules do not depend on metrics, but time. With this, it is possible to give a time to scale up automatically (ex: every morning), and then scale down (ex: evenings). Thanks to this, it is possible to automatically scale the website depending on the time, the date, or events, such as promotions, holiday sale, etc.

Documentation: <https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-autoscale-overview>

## Creation of the auto scaler

source of this part: <https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/tutorial-autoscale-cli?tabs=Ubuntu>

### Create an image from the existing VM

To enable autoscaling on a scale set, you first define an autoscale profile. This profile defines the default, minimum, and maximum scale set capacity.<br>
Unfortunately, the autoscaling doesn't work on standard VMs... It can be set on VMSSes: Virtual Machine Scale Sets.

### Create the VMSS

#### Before creating it

Before creating it, we need to deallocate the VM:

```PowerShell
az vm deallocate --resource-group <Resource group> --name <Instance Name>
```

And then Generalize it:

```PowerShell
az vm generalize --resource-group <Resource group> --name <Instance Name>
```

After these 2 steps, we can create the image:

```PowerShell
az image create --resource-group <Resource group> --name <Image name> --source <source name>
```

#### The creation

To create the VMSS, we need to create a new subnet:

```PowerShell
az network vnet subnet create --resource-group <Resource Group> --vnet-name <Virtual Network Name> --name <New Subnet Name> --address-prefix <address prefix>
```

Now, with our image, we can create the VMSS:

```PowerShell
az vmss create --resource-group <resource group> --name <vmss name> --image <image name> --upgrade-policy-mode Automatic --admin-username azureuser --generate-ssh-keys --subnet <subnet id>
```

To get the subnet's id:

```PowerShell
az network vnet subnet show --resource-group <resource group> --vnet-name <virtual network name> --name <subnet name> --query id --output tsv
```

#### The configuration

Now it is created, we need to configure the rules for the auto scaling.
This command can be used to create the autoscaling's configuration:

```PowerShell
az monitor autoscale create --resource-group <Resource Group> --resource <New Resource name> --resource-type Microsoft.Compute/virtualMachineScaleSets --name autoscale --min-count <min of VMs up> --max-count <Max of VMs up> --count <Default quantity>
```

What we want is to scale it depending on the used CPU. So, to define the rules, we can execute this:

```PowerShell
az monitor autoscale rule create --resource-group <Resource Group> --autoscale-name autoscale --scale out 1 --condition "Percentage CPU > 75 avg 5m"

az monitor autoscale rule create --resource-group <Resource Group> --autoscale-name autoscale --scale in 1 --condition "Percentage CPU < 75 avg 5m"
```

Those 2 rules define the auto scaling up, and the auto scaling down.

### Security

To finish this chapter, I'd like to say one last thing: Thanks to Azure, it is possible to protect the website from DDoS attacks. It can be done from the public address, under "protect an IP address".

## Summary

A VMSS is an object similar to a VM, but that can be auto scaled. The auto scaling is defined thanks to a bunch of rules, and the load balancing is automatized. So, no need for any load balancer.
The VMSS is created from a VM image, meaning it will be its true copy.