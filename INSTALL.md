# Instalando o ContainerLogV2 (segunda instância do ama-logs)

Este repositório é o chart `azuremonitor-containers` reduzido aos templates do
ContainerLogV2 (`templates/ama-logs-*`). Ele instala um segundo agente de logs
no mesmo cluster, apontando para outro Log Analytics workspace.

## Colisão com o addon gerenciado do AKS

O chart original cria objetos **globais com nomes fixos**, sem prefixo de
release:

| Objeto | Nome original |
|---|---|
| ServiceAccount / DaemonSet / PriorityClass | `ama-logs` |
| Secret | `ama-logs-secret` |
| ConfigMap | `ama-logs-rs-config` |
| Deployment | `ama-logs-rs` |
| DaemonSet (Windows) | `ama-logs-windows` |
| ClusterRole | `ama-logs-reader` |
| ClusterRoleBinding | `amalogsclusterrolebinding` |

Se o mesmo cluster já tem o addon gerenciado instalado
(`azure-monitor-logs-addon-*`, namespace `kube-system`), uma segunda instalação
sem prefixo faz o Helm ou falhar com `invalid ownership metadata`, ou **adotar e
sobrescrever** os objetos do addon de produção — e no `helm uninstall` deletar a
ServiceAccount / ClusterRole / ClusterRoleBinding que o addon ainda usa.

Por isso todos os objetos criados aqui são prefixados por
`amalogs.namePrefix` (default `v2`), incluindo os labels seletores dos
DaemonSet/Deployment, que senão fariam os controllers adotarem pods um do
outro.

```
v2-ama-logs                    ServiceAccount, DaemonSet, PriorityClass
v2-ama-logs-windows            DaemonSet (Windows)
v2-ama-logs-rs                 Deployment (rules engine)
v2-ama-logs-secret             Secret com WSID/KEY
v2-ama-logs-rs-config          ConfigMap do fluentd
v2-ama-logs-reader             ClusterRole
v2-ama-logs-clusterrolebinding ClusterRoleBinding
v2-ama-logs-ds / -rs           labels seletores
```

Os ConfigMaps `container-azm-ms-agentconfig` e `container-azm-ms-osmconfig`
**não** são prefixados de propósito: são criados pelo addon gerenciado e
marcados como `optional: true`.

## Instalação

Este repositório já é o chart — não use `helm pull`.

```bash
kubectl create namespace kube-monitor

helm install azure-monitor-v2 . \
  --namespace kube-monitor \
  --set amalogs.namePrefix="v2" \
  --set amalogs.namespace=kube-monitor \
  --set amalogs.secret.wsid="35cdd6a9-70ab-4a9f-8f2c-4e4c16ea3351" \
  --set amalogs.secret.key="SUA_LOG_ANALYTICS_PRIMARY_KEY" \
  --set amalogs.env.clusterName="aks-fintech-prod"
```

Para manter o agente no mesmo namespace do addon (default do chart):

```bash
helm install azure-monitor-v2 . \
  --namespace kube-system \
  --set amalogs.namePrefix="v2" \
  --set amalogs.secret.wsid="35cdd6a9-70ab-4a9f-8f2c-4e4c16ea3351" \
  --set amalogs.secret.key="SUA_LOG_ANALYTICS_PRIMARY_KEY" \
  --set amalogs.env.clusterName="aks-fintech-prod"
```

### Obter a chave do workspace

```bash
az monitor log-analytics workspace get-shared-keys \
  --resource-group rg-pixparcelado-prod \
  --workspace-name log-pixparcel-prod-us \
  --query primarySharedKey -o tsv
```

### Notas

- `amalogs.namePrefix` aceita `v2` ou `v2-` (o traço final é opcional). Use
  `""` para reproduzir os nomes originais do chart — **não** use isso se o
  addon gerenciado já estiver instalado.
- `--set amalogs.namespace` define onde os objetos são criados. Se for
  diferente do `--namespace` do release, crie o namespace antes.
- `amalogs.adxSecretName` permite reaproveitar um secret ADX já existente; sem
  ele, o chart referencia `v2-ama-logs-adx-secret`, que não é criado por este
  chart (`optional: true`).
- A chave do workspace fica exposta no Secret do release Helm. Considere
  `az aks get-credentials` + workload identity em vez de chave compartilhada.
- Os dois agentes leem os mesmos hostPaths (`/var/log`,
  `/var/lib/docker/containers`); apenas leitura, sem escrita concorrente.
- Se `amalogs.syslog.enabled=true`, o `hostPort` (`28330`) colide entre as duas
  instâncias. Mantenha `false` (default) na segunda instância.