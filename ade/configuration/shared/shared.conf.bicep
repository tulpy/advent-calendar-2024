@export()
var resPrefixes = {
  resourceGroup: 'arg'
  devCenter: 'adc'
  project: 'prj'
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
    name: 'win11-vs2022-vscode'
    image: 'win11-ent-vs2022'
    compute: '16c-64gb'
    storage: '512gb'
  }
  {
    name: 'win11-m365'
    image: 'win11-ent-m365'
    compute: '16c-64gb'
    storage: '512gb'
  }
  {
    name: 'win11-base'
    image: 'win11-ent-base'
    compute: '8c-32gb'
    storage: '256gb'
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
