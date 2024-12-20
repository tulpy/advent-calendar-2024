@export()
var resPrefixes = {
  resourceGroup: 'arg'
  devCenter: 'adc'
  project: 'prj'
  virtualNetwork: 'vnt'
  networkSecurityGroup: 'nsg'
  routeTable: 'udr'
}

@export()
var locPrefixes = {
  australiaEast: 'syd'
}

@export()
var delimeters = {
  dash: '-'
  none: ''
}

@export()
var definitions = [
  {
    name: 'win11-vs2022-vscode-8-32-256'
    image: 'win11-ent-vs2022'
    sku: '8-vcpu-32gb-ram-256-ssd'
  }
  {
    name: 'win11-vs2022-vscode-8-32-512'
    image: 'win11-ent-vs2022'
    sku: '8-vcpu-32gb-ram-512-ssd'
  }  
  {
    name: 'win11-vs2022-vscode-8-32-1024'
    image: 'win11-ent-vs2022'
    sku: '8-vcpu-32gb-ram-1024-ssd'
  }
  {
    name: 'win11-vs2022-vscode-8-32-2048'
    image: 'win11-ent-vs2022'
    sku: '8-vcpu-32gb-ram-2048-ssd'
  }
  {
    name: 'win11-vs2022-vscode-16-64-256'
    image: 'win11-ent-vs2022'
    sku: '16-vcpu-64gb-ram-256-ssd'
  }
  {
    name: 'win11-vs2022-vscode-16-64-512'
    image: 'win11-ent-vs2022'
    sku: '16-vcpu-64gb-ram-512-ssd'
  }
  {
    name: 'win11-vs2022-vscode-16-64-1024'
    image: 'win11-ent-vs2022'
    sku: '16-vcpu-64gb-ram-1024-ssd'
  }
  {
    name: 'win11-vs2022-vscode-16-64-2048'
    image: 'win11-ent-vs2022'
    sku: '16-vcpu-64gb-ram-2048-ssd'
  }
  {
    name: 'win11-vs2022-vscode-32-128-512'
    image: 'win11-ent-vs2022'
    sku: '32-vcpu-128gb-ram-512-ssd'
  }
  {
    name: 'win11-vs2022-vscode-32-128-1024'
    image: 'win11-ent-vs2022'
    sku: '32-vcpu-128gb-ram-1024-ssd'
  }
  {
    name: 'win11-vs2022-vscode-32-128-2048'
    image: 'win11-ent-vs2022'
    sku: '32-vcpu-128gb-ram-2048-ssd'
  }
]

@export()
var pools = [
  {
    administrator: 'Enabled'
    definition: 'win11-vs2022-vscode'
    displayName: 'Windows 11 Enterprise with VS 2022 and VS Code'
    name: 'win11-vs2022-vscode-pool'
  }
]

@export()
var sharedNSGrulesInbound = [
  {
    name: 'INBOUND-FROM-virtualNetwork-TO-virtualNetwork-PORT-any-PROT-Icmp-ALLOW'
    properties: {
      protocol: 'Icmp'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '*'
      destinationPortRanges: []
      sourceAddressPrefix: 'VirtualNetwork'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Allow'
      priority: 1000
      direction: 'Inbound'
      description: 'Shared - Allow Outbound ICMP traffic (Port *) from the subnet.'
    }
  }
  {
    name: 'INBOUND-FROM-any-TO-any-PORT-any-PROT-any-DENY'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '*'
      destinationPortRanges: []
      sourceAddressPrefix: '*'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: '*'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Deny'
      priority: 4096
      direction: 'Inbound'
      description: 'Shared - Deny Inbound traffic (Port *) from the subnet.'
    }
  }
]

@export()
var sharedNSGrulesOutbound = [
  {
    name: 'OUTBOUND-FROM-virtualNetwork-TO-virtualNetwork-PORT-any-PROT-Icmp-ALLOW'
    properties: {
      protocol: 'Icmp'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '*'
      destinationPortRanges: []
      sourceAddressPrefix: 'VirtualNetwork'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Allow'
      priority: 1000
      direction: 'Outbound'
      description: 'Shared - Allow Outbound ICMP traffic (Port *) from the subnet.'
    }
  }
  {
    name: 'OUTBOUND-FROM-virtualNetwork-TO-virtualNetwork-PORT-any-PROT-any-ALLOW'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '*'
      destinationPortRanges: []
      sourceAddressPrefix: 'VirtualNetwork'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Allow'
      priority: 1001
      direction: 'Outbound'
      description: 'Shared - Allow Outbound Virtual Network to Virtual Network traffic (Port *) from the subnet.'
    }
  }
  {
    name: 'OUTBOUND-FROM-subnet-TO-any-PORT-443-PROT-Tcp-ALLOW'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '443'
      destinationPortRanges: []
      sourceAddressPrefix: '*'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: '*'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Allow'
      priority: 1150
      direction: 'Outbound'
      description: 'Shared - Allow Outbound HTTPS traffic (Port 443) from the subnet.'
    }
  }
  {
    name: 'OUTBOUND-FROM-subnet-TO-KMS-PORT-1688-PROT-Tcp-ALLOW'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '1688'
      destinationPortRanges: []
      sourceAddressPrefix: '*'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: ''
      destinationAddressPrefixes: ['20.118.99.224/32', '40.83.235.53/32', '23.102.135.246/32']
      destinationApplicationSecurityGroupIds: []
      access: 'Allow'
      priority: 1200
      direction: 'Outbound'
      description: 'Shared - Allow Outbound KMS traffic (Port 1688) from the subnet.'
    }
  }
]

@export()
var routes = [
  {
    name: 'FROM-subnet-TO-default-0.0.0.0-0'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '1.1.1.1'
    }
  }
]
