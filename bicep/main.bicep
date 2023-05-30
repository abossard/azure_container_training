param location string = 'westeurope'
param resourceGroupName string = 'mt3chained'
param resourceGroupName2 string = 'mt3gateway'
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
    location: location
  }
}

module gateway 'mt3gateway.bicep' = {
  scope: resourceGroup2
  name: 'gateway'
  params: {
    location: location
  }
}
