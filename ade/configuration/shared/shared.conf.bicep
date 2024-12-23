@export()
var resPrefixes = {
  resourceGroup: 'arg'
  devCenter: 'adc'
  project: 'prj'
  networkConnection: 'nwc'
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
    name: 'win11-vs2022-vscode-pool'
    displayName: 'Windows 11 Enterprise with VS 2022 and VS Code'
    definition: 'win11-vs2022-vscode'
    administrator: 'Enabled'
    licenseType: 'Windows_Client'
    singleSignOnStatus: 'Enabled'
  }
]
