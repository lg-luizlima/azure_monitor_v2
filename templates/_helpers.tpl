{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "azuremonitor-containers.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "azuremonitor-containers.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "azuremonitor-containers.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Prefix applied to every object name created by this chart.
Set it to run this chart side by side with another ama-logs installation
(the AKS managed addon uses no prefix). Keep it empty to reproduce the
upstream object names. A trailing dash is optional.
*/}}
{{- define "azuremonitor-containers.namePrefix" -}}
{{- with .Values.amalogs.namePrefix -}}
{{- . | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Namespace the ama-logs objects are created in.
*/}}
{{- define "azuremonitor-containers.namespace" -}}
{{- default "kube-system" .Values.amalogs.namespace -}}
{{- end -}}

{{/*
Base name shared by the ama-logs workloads, service account and priority
class, e.g. "v2-ama-logs".
*/}}
{{- define "azuremonitor-containers.amalogsName" -}}
{{- $prefix := include "azuremonitor-containers.namePrefix" . -}}
{{- if $prefix -}}{{- printf "%s-" $prefix -}}{{- end -}}
{{- print "ama-logs" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
ClusterRole read by the ama-logs service accounts.
*/}}
{{- define "azuremonitor-containers.amalogsReaderName" -}}
{{- printf "%s-reader" (include "azuremonitor-containers.amalogsName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
ClusterRoleBinding granting the ama-logs reader role to the service account.
*/}}
{{- define "azuremonitor-containers.amalogsClusterRoleBindingName" -}}
{{- printf "%s-clusterrolebinding" (include "azuremonitor-containers.amalogsName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Secret holding the workspace id and key.
*/}}
{{- define "azuremonitor-containers.amalogsSecretName" -}}
{{- printf "%s-secret" (include "azuremonitor-containers.amalogsName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Fluentd configuration used by the rule processing deployment.
*/}}
{{- define "azuremonitor-containers.amalogsRsConfigName" -}}
{{- printf "%s-rs-config" (include "azuremonitor-containers.amalogsName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Rule processing deployment name and its pod selector label.
*/}}
{{- define "azuremonitor-containers.amalogsRsName" -}}
{{- printf "%s-rs" (include "azuremonitor-containers.amalogsName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Windows daemonset name.
*/}}
{{- define "azuremonitor-containers.amalogsWindowsName" -}}
{{- printf "%s-windows" (include "azuremonitor-containers.amalogsName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Pod selector label of the linux and windows daemonsets.
*/}}
{{- define "azuremonitor-containers.amalogsDsLabel" -}}
{{- printf "%s-ds" (include "azuremonitor-containers.amalogsName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Optional secret with the ADX / data collection endpoint credentials.
It is not created by this chart: falls back to the prefixed name so a
dedicated secret can be provided for this installation.
*/}}
{{- define "azuremonitor-containers.amalogsAdxSecretName" -}}
{{- if .Values.amalogs.adxSecretName -}}
{{- .Values.amalogs.adxSecretName -}}
{{- else -}}
{{- printf "%s-adx-secret" (include "azuremonitor-containers.amalogsName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
