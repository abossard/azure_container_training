# Azure Container Training

## Applications

### Mathtrick
An application that does a cool math trick. There are two version, one with a chained function call and one where the calls go through a gateway.

### Docker Images and Environment Variables:
All support `APPINSIGHTS_INSTRUMENTATIONKEY` to log to Application Insights
#### MathTrick Chained
- `docker.io/scubakiz/mt3chained-web`
  - `MT3ChainedAPIEndpoint`: The endpoint where docker.io/scubakiz/mt3chained-step1 is hosted
- `docker.io/scubakiz/mt3chained-step1`
  - `NextStepEndpoint`: The endpoint where docker.io/scubakiz/mt3chained-step2 is hosted
- `docker.io/scubakiz/mt3chained-step2`
    - `NextStepEndpoint`: The endpoint where docker.io/scubakiz/mt3chained-step3 is hosted
- `docker.io/scubakiz/mt3chained-step3`
    - `NextStepEndpoint`: The endpoint where docker.io/scubakiz/mt3chained-step4 is hosted
- `docker.io/scubakiz/mt3chained-step4`
    - `NextStepEndpoint`: The endpoint where docker.io/scubakiz/mt3chained-step5 is hosted
- `docker.io/scubakiz/mt3chained-step5`

#### MathTrick Gateway
- `docker.io/scubakiz/mt3gateway-web`
    - `MT3GatewayAPIEndpoint`: The endpoint where docker.io/scubakiz/mt3gateway-api is hosted
- `docker.io/scubakiz/mt3gateway-gateway`
    - `MT3GatewayStep1Endpoint`: The endpoint where docker.io/scubakiz/mt3gateway-step1 is hosted
    - `MT3GatewayStep2Endpoint`: The endpoint where docker.io/scubakiz/mt3gateway-step2 is hosted
    - `MT3GatewayStep3Endpoint`: The endpoint where docker.io/scubakiz/mt3gateway-step3 is hosted
    - `MT3GatewayStep4Endpoint`: The endpoint where docker.io/scubakiz/mt3gateway-step4 is hosted
    - `MT3GatewayStep5Endpoint`: The endpoint where docker.io/scubakiz/mt3gateway-step5 is hosted
- `docker.io/scubakiz/mt3gateway-step1`
- `docker.io/scubakiz/mt3gateway-step2`
- `docker.io/scubakiz/mt3gateway-step3`
- `docker.io/scubakiz/mt3gateway-step4`
- `docker.io/scubakiz/mt3gateway-step5`