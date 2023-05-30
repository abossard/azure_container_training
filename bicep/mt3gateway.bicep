param location string = resourceGroup().location
param salt string = substring(uniqueString(resourceGroup().id), 0, 3)
param containerapps_mt3_name string = 'mt3-web-${salt}'
param containerapps_gateway_name string = 'gateway-${salt}'
param containerapps_step_1_name string = 'step-1-gateway-${salt}'
param containerapps_step_2_name string = 'step-2-gateway-${salt}'
param containerapps_step_3_name string = 'step-3-gateway-${salt}'
param containerapps_step_4_name string = 'step-4-gateway-${salt}'
param containerapps_step_5_name string = 'step-5-gateway-${salt}'
param components_appinsightsgateway_name string = 'appinsightsgateway${salt}'
param workspace_name string = 'workspacemathtrick3gateway${salt}'
param managedEnvironment_name string = 'managedEnvironment-mathtrick3-${salt}'

param tags object = {
  mode: 'gateway'
}

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
          image: 'docker.io/scubakiz/mt3gateway-web'
          name: containerapps_mt3_name
          env: [
            {
              name: 'MT3GatewayAPIEndpoint'
              value: 'https://${containerapps_gateway_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightsgateway_resource.properties.InstrumentationKey
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
        minReplicas: 0
        maxReplicas: 10
      }
    }
  }
}


resource containerapps_gateway_resource 'Microsoft.App/containerapps@2022-11-01-preview' = {
  name: containerapps_gateway_name
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
          image: 'docker.io/scubakiz/mt3gateway-gateway'
          name: containerapps_mt3_name
          env: [
            {
              name: 'MT3GatewayStep1Endpoint'
              value: 'https://${containerapps_step_1_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'MT3GatewayStep2Endpoint'
              value: 'https://${containerapps_step_2_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'MT3GatewayStep3Endpoint'
              value: 'https://${containerapps_step_3_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'MT3GatewayStep4Endpoint'
              value: 'https://${containerapps_step_4_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'MT3GatewayStep5Endpoint'
              value: 'https://${containerapps_step_5_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightsgateway_resource.properties.InstrumentationKey
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
        minReplicas: 0
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
      revisionSuffix: 'api'
      containers: [
        {
          image: 'docker.io/scubakiz/mt3gateway-step1'
          name: containerapps_step_1_name
          env: [
            {
              name: 'NextStepEndpoint'
              value: 'https://${containerapps_step_2_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightsgateway_resource.properties.InstrumentationKey
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
        minReplicas: 0
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
          image: 'docker.io/scubakiz/mt3gateway-step2'
          name: containerapps_step_2_name
          env: [
            {
              name: 'NextStepEndpoint'
              value: 'https://${containerapps_step_3_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightsgateway_resource.properties.InstrumentationKey
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
        minReplicas: 0
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
          image: 'docker.io/scubakiz/mt3gateway-step3'
          name: containerapps_step_3_name
          env: [
            {
              name: 'NextStepEndpoint'
              value: 'https://${containerapps_step_4_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightsgateway_resource.properties.InstrumentationKey
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
        minReplicas: 0
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
          image: 'docker.io/scubakiz/mt3gateway-step4'
          name: containerapps_step_4_name
          env: [
            {
              name: 'NextStepEndpoint'
              value: 'https://${containerapps_step_5_resource.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightsgateway_resource.properties.InstrumentationKey
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
        minReplicas: 0
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
          image: 'docker.io/scubakiz/mt3gateway-step5'
          name: containerapps_step_5_name
          env: [
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: components_appinsightsgateway_resource.properties.InstrumentationKey
            }
          ]
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 10
      }
    }
  }
}

resource components_appinsightsgateway_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_appinsightsgateway_name
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

output mathtrick3gateway_endpoint string = 'https://${containerapps_mt3_resource.properties.configuration.ingress.fqdn}'
