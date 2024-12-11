import * as shared from '../../configuration/shared/shared.conf.bicep'
import * as type from '../../configuration/shared/shared.types.bicep'

targetScope = 'resourceGroup'

metadata name = 'ALZ Bicep - Spoke Networking module'
metadata description = 'Deploy the Spoke Networking Module for Azure Landing Zones'
metadata version = '1.1.0'
metadata author = 'Insight APAC Platform Engineering'

// Common Parameters
@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags type.tagsType

// Virtual Network Parameters
@description('Required. The name of the Virtual Network (vNet).')
param virtualNetworkName string

@description('Optional. The DdosProtectionPlan Id which will be applied to the Virtual Network.')
param ddosProtectionPlanId string = ''

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes string

@description('Optional. DNS Servers associated to the Virtual Network.')
param dnsServerIps array = []

@description('Required. An Array of subnets to deploy to the Virtual Network.')
param subnets type.subnetType

@description('Optional. Switch to disable BGP route propagation.')
param disableBgpRoutePropagation bool = false

@description('Optional. The IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance.')
param nextHopIpAddress string = ''

// Module: Virtual Network - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/virtual-network
module virtualNetwork 'br/public:avm/res/network/virtual-network:0.5.1' = {
  name: take('virtualNetwork-${guid(deployment().name)}', 64)
  dependsOn: [
    networkSecurityGroup
  ]
  params: {
    // Required parameters
    addressPrefixes: [
      addressPrefixes
    ]
    name: virtualNetworkName
    // Non-required parameters
    ddosProtectionPlanResourceId: (!empty(ddosProtectionPlanId) ? ddosProtectionPlanId : null)
    dnsServers: (!empty(dnsServerIps) ? dnsServerIps : null)
    location: location
    subnets: [
      for (subnet, index) in (subnets ?? []): {
        name: subnet.name
        addressPrefix: subnet.addressPrefix
        addressPrefixes: []
        networkSecurityGroupResourceId: (!empty(subnet.networkSecurityGroupName))
          ? resourceId('Microsoft.Network/networkSecurityGroups', '${subnet.networkSecurityGroupName}')
          : null
        routeTableResourceId: (!empty(nextHopIpAddress) && !empty(subnet.routeTableName))
          ? resourceId('Microsoft.Network/routeTables', '${subnet.routeTableName}')
          : null
        delegation: subnet.delegation
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        serviceEndpointPolicies: !empty(subnet.serviceEndpointPolicies) ? subnet.serviceEndpointPolicies : null
        serviceEndpoints: !empty(subnet.serviceEndpointPolicies) ? subnet.serviceEndpointPolicies : null
      }
    ]
    tags: tags
  }
}

// Module: Network Security Group - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/network-security-group
module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = [
  for (subnet, i) in (subnets ?? []): if (!empty(subnet.networkSecurityGroupName)) {
    name: 'nsg-${i}'
    params: {
      // Required parameters
      name: subnet.networkSecurityGroupName
      // Non-required parameters
      location: location
      securityRules: concat(shared.sharedNSGrulesInbound, shared.sharedNSGrulesOutbound, subnet.securityRules)
      tags: tags
    }
  }
]

// Module: Route Table - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/route-table
module routeTable 'br/public:avm/res/network/route-table:0.4.0' = [
  for (subnet, i) in (subnets ?? []): if (!empty(nextHopIpAddress) && !empty(subnet.routeTableName)) {
    name: 'routeTable-${i}'
    params: {
      // Required parameters
      name: subnet.routeTableName
      // Non-required parameters
      disableBgpRoutePropagation: disableBgpRoutePropagation
      location: location
      routes: concat(shared.routes, subnet.routes)
      tags: tags
    }
  }
]

// Outputs
@description('The Virtual Network Resource Id.')
output virtualNetworkId string = virtualNetwork.outputs.resourceId

@description('The Virtual Network Name.')
output virtualNetworkName string = virtualNetwork.name

@description('An array of Network Security Groups.')
output networkSecurityGroup array = [
  for (subnet, i) in (subnets ?? []): {
    name: !empty(subnet.networkSecurityGroupName) ? networkSecurityGroup[i].outputs.name : null
    id: !empty(subnet.networkSecurityGroupName) ? networkSecurityGroup[i].outputs.resourceId : null
  }
]

@description('An array of Route Tables.')
output routeTable array = [
  for (subnet, i) in (subnets ?? []): {
    name: !empty(nextHopIpAddress) && !empty(subnet.routeTableName) ? routeTable[i].outputs.name : null
    id: !empty(nextHopIpAddress) && !empty(subnet.routeTableName) ? routeTable[i].outputs.resourceId : null
  }
]
