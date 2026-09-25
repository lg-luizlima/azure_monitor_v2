
Quero instalar o ContainerLogV2 no mesmo cluster

helm pull microsoft/azuremonitor-containers --untar

helm install azure-monitor-v2 ./ \
  --namespace kube-monitor \
  --set fullnameOverride="ama-logs-v2" \
  --set values.containerLogV2.enabled=true \
  --set amalogsagent.secret.wsid="35cdd6a9-70ab-4a9f-8f2c-4e4c16ea3351" \
  --set amalogsagent.secret.key="SUA_LOG_ANALYTICS_PRIMARY_KEY" \
  --set amalogsagent.env.clusterName="aks-fintech-prod"


az monitor log-analytics workspace get-shared-keys \
--resource-group rg-pixparcelado-prod \
--workspace-name log-pixparcel-prod-us \
--query primarySharedKey -o tsv


Observacao ja tenho instalado no mesmo cluster outro helm que aponta pra ContainerLog

Chart
azure-monitor-logs-addon-3.1.35-ea2889c21bb378c00f380d5f560b2cfd4261cfe1
Updated
170d ago (08 de abr. de 2026, 3:05:33 BRT)
Namespace
kube-system
Version
3.1.35-ea2889c21bb378c00f380d5f560b2cfd4261cfe1
Status
Deployed

Helm Chart padrão do Azure Monitor possui objetos globais rígidos (como ClusterRole, ClusterRoleBinding e CRDs) cujos nomes são fixos no código do Chart. Se a segunda instalação tentar criá-los, o Kubernetes bloqueará informando que o recurso já existe, ou ela sobrescreverá as permissões do seu agente de produção atual, gerando instabilidade.