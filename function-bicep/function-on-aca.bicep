param location string = resourceGroup().location

param salt string = toLower(substring(uniqueString(resourceGroup().id), 0, 4))
param storageAccountName string = 'funcstor'
param logAnalyticsWorkspaceName string = 'funcla'
param appInsightsName string = 'funcappi'
param acaEnvironmentName string = 'funcenv'
param funcAppName string = 'funcapp'

/* ###################################################################### */
// Create storage account for function app prereq
/* ###################################################################### */
resource azStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${storageAccountName}${salt}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${logAnalyticsWorkspaceName}${salt}'
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appInsightsName}${salt}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource managedEnvironment 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: '${acaEnvironmentName}${salt}'
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

var connectionString = 'DefaultEndpointsProtocol=https;AccountName=${azStorageAccount.name};AccountKey=${azStorageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

resource azfunctionapp 'Microsoft.Web/sites@2022-09-01' = {
  name: '${funcAppName}${salt}'
  location: location
  kind: 'functionapp'
  properties: {
    name: '${funcAppName}${salt}'
    managedEnvironmentId: managedEnvironment.id
    siteConfig: {
      linuxFxVersion: 'Docker|mcr.microsoft.com/azure-functions/dotnet7-quickstart-demo:1.0'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: connectionString
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
  }
}

// output functionAppName string = azfunctionapp.name
