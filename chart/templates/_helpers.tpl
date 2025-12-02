{{/*
Namespace - uses global.namespace if set, otherwise .Release.Namespace
*/}}
{{- define "linea-dev.namespace" -}}
{{- if .Values.global.namespace }}
{{- .Values.global.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "linea-dev.name" -}}
{{- if .Values.nameOverride }}
{{- .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "linea-dev.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "linea-dev.labels" -}}
helm.sh/chart: {{ include "linea-dev.chart" . }}
{{ include "linea-dev.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- with .Values.global.labels }}
{{- range $key, $value := . }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "linea-dev.selectorLabels" -}}
app.kubernetes.io/name: {{ include "linea-dev.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component-specific name
Usage: {{ include "linea-dev.component.name" (dict "component" "sequencer" "root" .) }}
Dict Example: { "component": "sequencer", "root": { <root context> } }
*/}}
{{- define "linea-dev.component.name" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- printf "%s-%s" (include "linea-dev.name" $root) $component | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Component-specific selector labels
Usage: {{ include "linea-dev.component.selectorLabels" (dict "component" "sequencer" "root" .) }}
Dict Example: { "component": "sequencer", "root": { <root context> } }
*/}}
{{- define "linea-dev.component.selectorLabels" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{ include "linea-dev.selectorLabels" $root }}
app.kubernetes.io/component: {{ $component }}
{{- end }}

{{/*
Component-specific labels
Usage: {{ include "linea-dev.component.labels" (dict "component" "sequencer" "root" .) }}
Dict Example: { "component": "sequencer", "root": { <root context> } }
*/}}
{{- define "linea-dev.component.labels" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{ include "linea-dev.labels" $root }}
app.kubernetes.io/component: {{ $component }}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "linea-dev.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else }}
{{- include "linea-dev.name" . }}
{{- end }}
{{- else }}
{{- "default" }}
{{- end }}
{{- end }}

{{/*
Global annotations
Usage: {{ include "linea-dev.global.annotations" . }}
*/}}
{{- define "linea-dev.global.annotations" -}}
{{- with .Values.global.annotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Component-specific annotations
Usage: {{ include "linea-dev.component.annotations" (dict "component" "sequencer" "root" .) }}
*/}}
{{- define "linea-dev.component.annotations" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $componentValues := index $root.Values $component -}}
{{- include "linea-dev.global.annotations" $root }}
{{- with $componentValues.podAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Service annotations
Usage: {{ include "linea-dev.service.annotations" (dict "component" "sequencer" "root" .) }}
*/}}
{{- define "linea-dev.service.annotations" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $componentValues := index $root.Values $component -}}
{{- include "linea-dev.global.annotations" $root }}
{{- with $componentValues.service.annotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Component-specific labels
Usage: {{ include "linea-dev.component.labels.with.custom" (dict "component" "sequencer" "customLabels" .Values.sequencer.podLabels "root" .) }}
*/}}
{{- define "linea-dev.component.labels.with.custom" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $customLabels := .customLabels -}}
{{ include "linea-dev.component.labels" (dict "component" $component "root" $root) }}
{{- with $customLabels }}
{{- range $key, $value := . }}
{{- if ne $key "app.kubernetes.io/component" }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
