param location string = resourceGroup().location
param salt string = substring(uniqueString(resourceGroup().id), 0, 3)
param containerapps_mt3_name string = 'mt3-chained-${salt}'
param containerapps_step_1_name string = 'step-1-chained-${salt}'
param containerapps_step_2_name string = 'step-2-chained-${salt}'
param containerapps_step_3_name string = 'step-3-chained-${salt}'
param minScale int = 0
param containerapps_step_4_name string = 'step-4-chained-${salt}'
param containerapps_step_5_name string = 'step-5-chained-${salt}'
param components_appinsightschained_name string = 'appinsightschained${salt}'
param workspace_name string = 'workspacemathtrick3${salt}'
param managedEnvironment_name string = 'managedEnvironment-mathtrick3-${salt}'

resource managedEnvironment_resource 'Microsoft.App/managedEnvironments@2022-11-01-preview' = {
  name: managedEnvironment_name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: workspace_resource.properties.customerId
        sharedKey: workspace_resource.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
    kedaConfiguration: {}
    daprConfiguration: {}
    customDomainConfiguration: {}
  }
}

resource workspace_resource 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: workspace_name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource containerapps_mt3_resource 'Microsoft.App/containerapps@2022-11-01-preview' = {
  name: containerapps_mt3_name
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: managedEnvironment_resource.id
    environmentId: managedEnvironment_resource.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 80
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
    }
    template: {
      containers: [
        {
          image: 'docker.io/scubakiz/mt3chained-web'
          name: containerapps_mt3_name
          env: [
            {
              name: 'MT3ChainedAPIEndpoint'
              value: 'https://${containerapps_step_1_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightschained_resource.properties.InstrumentationKey
            }
          ]
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
          probes: []
        }
      ]
      scale: {
        minReplicas: minScale
        maxReplicas: 10
      }
    }
  }
}

resource containerapps_step_1_resource 'Microsoft.App/containerapps@2022-11-01-preview' = {
  name: containerapps_step_1_name
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: managedEnvironment_resource.id
    environmentId: managedEnvironment_resource.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 80
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
    }
    template: {
      containers: [
        {
          image: 'docker.io/scubakiz/mt3chained-step1'
          name: containerapps_step_1_name
          env: [
            {
              name: 'NextStepEndpoint'
              value: 'https://${containerapps_step_2_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightschained_resource.properties.InstrumentationKey
            }
          ]
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
          probes: []
        }
      ]
      scale: {
        minReplicas: minScale
        maxReplicas: 10
      }
    }
  }
}

resource containerapps_step_2_resource 'Microsoft.App/containerapps@2022-11-01-preview' = {
  name: containerapps_step_2_name
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: managedEnvironment_resource.id
    environmentId: managedEnvironment_resource.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 80
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
    }
    template: {
      containers: [
        {
          image: 'docker.io/scubakiz/mt3chained-step2'
          name: containerapps_step_2_name
          env: [
            {
              name: 'NextStepEndpoint'
              value: 'https://${containerapps_step_3_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightschained_resource.properties.InstrumentationKey
            }
          ]
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
          probes: []
        }
      ]
      scale: {
        minReplicas: minScale
        maxReplicas: 10
      }
    }
  }
}

resource containerapps_step_3_resource 'Microsoft.App/containerapps@2022-11-01-preview' = {
  name: containerapps_step_3_name
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: managedEnvironment_resource.id
    environmentId: managedEnvironment_resource.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 80
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
    }
    template: {
      containers: [
        {
          image: 'docker.io/scubakiz/mt3chained-step3'
          name: containerapps_step_3_name
          env: [
            {
              name: 'NextStepEndpoint'
              value: 'https://${containerapps_step_4_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightschained_resource.properties.InstrumentationKey
            }
          ]
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
          probes: []
        }
      ]
      scale: {
        minReplicas: minScale
        maxReplicas: 10
      }
    }
  }
}

resource containerapps_step_4_resource 'Microsoft.App/containerapps@2022-11-01-preview' = {
  name: containerapps_step_4_name
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: managedEnvironment_resource.id
    environmentId: managedEnvironment_resource.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 80
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
    }
    template: {
      containers: [
        {
          image: 'docker.io/scubakiz/mt3chained-step4'
          name: containerapps_step_4_name
          env: [
            {
              name: 'NextStepEndpoint'
              value: 'https://${containerapps_step_5_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightschained_resource.properties.InstrumentationKey
            }
          ]
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
          probes: []
        }
      ]
      scale: {
        minReplicas: minScale
        maxReplicas: 10
      }
    }
  }
}

resource containerapps_step_5_resource 'Microsoft.App/containerapps@2022-11-01-preview' = {
  name: containerapps_step_5_name
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: managedEnvironment_resource.id
    environmentId: managedEnvironment_resource.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 80
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
    }
    template: {
      containers: [
        {
          image: 'docker.io/scubakiz/mt3chained-step5'
          name: containerapps_step_5_name
          env: [
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightschained_resource.properties.InstrumentationKey
            }
          ]
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: minScale
        maxReplicas: 10
      }
    }
  }
}

resource components_appinsightschained_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_appinsightschained_name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
    RetentionInDays: 90
    WorkspaceResourceId: workspace_resource.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output mathtrick3chained_endpoint string = 'https://${containerapps_mt3_resource.properties.configuration.ingress.fqdn}'
