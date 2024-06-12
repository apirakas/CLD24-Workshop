# Create the Load Balancer
Here we will create the Load Balancer

We already have a ResourceGroup and a VirtualNetwork so it will not be covered here !

Reminder : 
- ResourceGroup = CLDWorkshop
- VirtualNetwork = StatelessInstanceVNET


### Create a Subnet
```PowerShell
[INPUT]
az network vnet subnet create  --resource-group CLDWorkshop --vnet-name StatelessInstanceVNET  --name LoadBalancerSubnet  --address-prefix 10.0.0.0/24
```

```JSON
[OUTPUT]
{
  "addressPrefix": "10.0.0.0/24",
  "delegations": [],
  "etag": "W/\"cdc5512d-42cf-4cee-bfd7-7542df4725b3\"",
  "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/virtualNetworks/StatelessInstanceVNET/subnets/LoadBalancerSubnet",
  "name": "LoadBalancerSubnet",
  "privateEndpointNetworkPolicies": "Disabled",
  "privateLinkServiceNetworkPolicies": "Enabled",
  "provisioningState": "Succeeded",
  "resourceGroup": "CLDWorkshop",
  "type": "Microsoft.Network/virtualNetworks/subnets"
}

```

#### We had to create a new subnet for instances because we wanted the LB subnet to have the 10.0.0.0/24 range... so here is the new InstanceSubnet with range 10.0.1.0/24

```PowerShell
[INPUT]
az network vnet subnet create  --resource-group CLDWorkshop --vnet-name StatelessInstanceVNET --name InstanceSubnet --address-prefix 10.0.1.0/24
```

```JSON
[OUTPUT]
{
  "addressPrefix": "10.0.1.0/24",
  "delegations": [],
  "etag": "W/\"a6f22d89-654e-4bb2-825e-00ddc6802e25\"",
  "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/virtualNetworks/StatelessInstanceVNET/subnets/InstanceSubnet",
  "name": "InstanceSubnet",
  "privateEndpointNetworkPolicies": "Disabled",
  "privateLinkServiceNetworkPolicies": "Enabled",
  "provisioningState": "Succeeded",
  "resourceGroup": "CLDWorkshop",
  "type": "Microsoft.Network/virtualNetworks/subnets"
}
```
### Create Public IP

```PowerShell
[INPUT]
az network public-ip create  --resource-group CLDWorkshop --name LoadBalancerPublicIP --allocation-method Static
```

```JSON
[OUTPUT]
{
  "publicIp": {
    "ddosSettings": {
      "protectionMode": "VirtualNetworkInherited"
    },
    "etag": "W/\"0d513073-b37f-4081-bc8b-ecac236368c4\"",
    "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/publicIPAddresses/LoadBalancerPublicIP",
    "idleTimeoutInMinutes": 4,
    "ipAddress": "172.161.134.28",
    "ipTags": [],
    "location": "switzerlandnorth",
    "name": "LoadBalancerPublicIP",
    "provisioningState": "Succeeded",
    "publicIPAddressVersion": "IPv4",
    "publicIPAllocationMethod": "Static",
    "resourceGroup": "CLDWorkshop",
    "resourceGuid": "0a078f44-5bc4-46fb-a17d-4c19c71c6310",
    "sku": {
      "name": "Standard",
      "tier": "Regional"
    },
    "type": "Microsoft.Network/publicIPAddresses"
  }
}
```

### Create Load Balancer

```PowerShell
[INPUT]
az network lb create  --resource-group CLDWorkshop --name PublicLoadBalancer --public-ip-address LoadBalancerPublicIP --frontend-ip-name FrontendIPConfig  --backend-pool-name BackendPool  --sku Standard
```

```JSON
[OUTPUT]
{
  "loadBalancer": {
    "backendAddressPools": [
      {
        "etag": "W/\"4f819a69-c17c-4679-90de-344e53d6a82e\"",
        "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/loadBalancers/PublicLoadBalancer/backendAddressPools/BackendPool",
        "name": "BackendPool",
        "properties": {
          "loadBalancerBackendAddresses": [],
          "provisioningState": "Succeeded"
        },
        "resourceGroup": "CLDWorkshop",
        "type": "Microsoft.Network/loadBalancers/backendAddressPools"
      }
    ],
    "frontendIPConfigurations": [
      {
        "etag": "W/\"4f819a69-c17c-4679-90de-344e53d6a82e\"",
        "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/loadBalancers/PublicLoadBalancer/frontendIPConfigurations/FrontendIPConfig",
        "name": "FrontendIPConfig",
        "properties": {
          "privateIPAllocationMethod": "Dynamic",
          "provisioningState": "Succeeded",
          "publicIPAddress": {
            "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/publicIPAddresses/LoadBalancerPublicIP",
            "resourceGroup": "CLDWorkshop"
          }
        },
        "resourceGroup": "CLDWorkshop",
        "type": "Microsoft.Network/loadBalancers/frontendIPConfigurations"
      }
    ],
    "inboundNatPools": [],
    "inboundNatRules": [],
    "loadBalancingRules": [],
    "outboundRules": [],
    "probes": [],
    "provisioningState": "Succeeded",
    "resourceGuid": "4055bcb7-2538-4f51-917a-f91f9eb03cf6"
  }
}
```

### Add NIC of VMs to the BackendPool
Doing this will inform the LoadBalancer which VMs are in his pool so he knows which one to call !

```PowerShell
[INPUT]
az network nic ip-config address-pool add --address-pool BackendPool --ip-config-name ipconfigStatelessInstance --nic-name StatelessInstanceVMNic  --resource-group CLDWorkshop --lb-name PublicLoadBalancer
```

```JSON
[OUTPUT]
{
  "etag": "W/\"ec210323-83f8-4a88-b593-55e4a8d1ad31\"",
  "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/networkInterfaces/StatelessInstanceVMNic/ipConfigurations/ipconfigStatelessInstance",
  "loadBalancerBackendAddressPools": [
    {
      "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/loadBalancers/PublicLoadBalancer/backendAddressPools/BackendPool",
      "resourceGroup": "CLDWorkshop"
    }
  ],
  "name": "ipconfigStatelessInstance",
  "primary": true,
  "privateIPAddress": "10.0.1.4",
  "privateIPAddressVersion": "IPv4",
  "privateIPAllocationMethod": "Dynamic",
  "provisioningState": "Succeeded",
  "publicIPAddress": {
    "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/publicIPAddresses/StatelessInstancePublicIP",
    "resourceGroup": "CLDWorkshop"
  },
  "resourceGroup": "CLDWorkshop",
  "subnet": {
    "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/virtualNetworks/StatelessInstanceVNET/subnets/InstanceSubnet",
    "resourceGroup": "CLDWorkshop"
  },
  "type": "Microsoft.Network/networkInterfaces/ipConfigurations"
}

```
### Create a Health Probe

```PowerShell
[INPUT]
az network lb probe create  --resource-group CLDWorkshop --lb-name PublicLoadBalancer --name PLBHealthProbe  --protocol tcp  --port 80
```

```JSON
[OUTPUT]
{
  "etag": "W/\"9838c591-3e02-4c30-970f-ea633681dde5\"",
  "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/loadBalancers/PublicLoadBalancer/probes/PLBHealthProbe",
  "intervalInSeconds": 15,
  "name": "PLBHealthProbe",
  "numberOfProbes": 2,
  "port": 80,
  "probeThreshold": 1,
  "protocol": "Tcp",
  "provisioningState": "Succeeded",
  "resourceGroup": "CLDWorkshop",
  "type": "Microsoft.Network/loadBalancers/probes"
}
```

### Finally, add rules to the load balancer

```Powershell
[INPUT]
az network lb rule create  --resource-group CLDWorkshop  --lb-name PublicLoadBalancer  --name HTTPRule  --protocol tcp  --frontend-ip-name FrontendIPConfig  --backend-pool-name BackendPool  --probe-name PLBHealthProbe  --frontend-port 80  --backend-port 80
```
```JSON
[OUTPUT]
{
  "backendAddressPool": {
    "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/loadBalancers/PublicLoadBalancer/backendAddressPools/BackendPool",
    "resourceGroup": "CLDWorkshop"
  },
  "backendAddressPools": [
    {
      "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/loadBalancers/PublicLoadBalancer/backendAddressPools/BackendPool",
      "resourceGroup": "CLDWorkshop"
    }
  ],
  "backendPort": 80,
  "disableOutboundSnat": false,
  "enableFloatingIP": false,
  "enableTcpReset": false,
  "etag": "W/\"93f2b3d0-3b5b-4cea-806d-0969d1967854\"",
  "frontendIPConfiguration": {
    "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/loadBalancers/PublicLoadBalancer/frontendIPConfigurations/FrontendIPConfig",
    "resourceGroup": "CLDWorkshop"
  },
  "frontendPort": 80,
  "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/loadBalancers/PublicLoadBalancer/loadBalancingRules/HTTPRule",
  "idleTimeoutInMinutes": 4,
  "loadDistribution": "Default",
  "name": "HTTPRule",
  "probe": {
    "id": "/subscriptions/a34a3ff1-f14c-498d-aa65-0707d5e729dc/resourceGroups/CLDWorkshop/providers/Microsoft.Network/loadBalancers/PublicLoadBalancer/probes/PLBHealthProbe",
    "resourceGroup": "CLDWorkshop"
  },
  "protocol": "Tcp",
  "provisioningState": "Succeeded",
  "resourceGroup": "CLDWorkshop",
  "type": "Microsoft.Network/loadBalancers/loadBalancingRules"
}
```

### All done !
Now that the Load balancer, remove the public IP of the stateless instance:

```PowerShell
[INPUT]

```

Now you can access the Load Balancer address here : http://172.161.134.28/

And you will be redirected to the application !!

