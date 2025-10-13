{{/* Expand the name of the chart. */}}
{{- define "task-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "task-manager.fullname" -}}
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

{{/* Create chart name and version as used by the chart label. */}}
{{- define "task-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Common labels applied to all resources. */}}
{{- define "task-manager.labels" -}}
helm.sh/chart: {{ include "task-manager.chart" . }}
{{ include "task-manager.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* Selector labels used for matchLabels. */}}
{{- define "task-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "task-manager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create a name for a component by suffixing the release fullname.
Usage: {{ include "task-manager.fullnameSuffix" (dict "root" . "suffix" "backend") }}
*/}}
{{- define "task-manager.fullnameSuffix" -}}
{{- $root := .root -}}
{{- $suffix := .suffix -}}
{{- printf "%s-%s" (include "task-manager.fullname" $root) $suffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Labels for a component with a specific role. */}}
{{- define "task-manager.componentLabels" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $labels := dict -}}
{{- $base := include "task-manager.labels" $root | fromYaml -}}
{{- if $base -}}
	{{- range $k, $v := $base -}}
		{{- $_ := set $labels $k $v -}}
	{{- end -}}
{{- end -}}
{{- $_ := set $labels "app.kubernetes.io/component" $component -}}
{{- toYaml $labels -}}
{{- end -}}

{{/* Create the name of the service account to use. */}}
{{- define "task-manager.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "task-manager.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}
