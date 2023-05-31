param location string = 'westeurope'
param resourceGroupName string = 'mt3chained'
param resourceGroupName2 string = 'mt3gateway'
param minScale int = 0
targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

resource resourceGroup2 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName2
  location: location
}

module chained 'mt3chained.bicep' = {
  scope: resourceGroup
  name: 'chained'
  params: {
    minScale: minScale
    location: location
  }
}

module gateway 'mt3gateway.bicep' = {
  scope: resourceGroup2
  name: 'gateway'
  params: {
    minScale: minScale
    location: location
  }
}

output chainedUrl string = chained.outputs.mathtrick3chained_endpoint
output gateqayUrl string = gateway.outputs.mathtrick3gateway_endpoint
