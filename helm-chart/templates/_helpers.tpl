{{/*
Expand the name of the chart.
*/}}
{{- define "powerpipe.name" -}}
powerpipe
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "powerpipe.fullname" -}}
{{- if .Values.powerpipe.fullnameOverride }}
{{- .Values.powerpipe.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.powerpipe.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "powerpipe.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "powerpipe.labels" -}}
helm.sh/chart: {{ include "powerpipe.chart" . }}
{{ include "powerpipe.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "powerpipe.selectorLabels" -}}
app.kubernetes.io/name: {{ include "powerpipe.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "powerpipe.serviceAccountName" -}}
default
{{- end }}


{{/*
Expand the name of the chart.
*/}}
{{- define "steampipe.name" -}}
steampipe
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "steampipe.fullname" -}}
{{- if .Values.steampipe.fullnameOverride }}
{{- .Values.steampipe.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.steampipe.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "steampipe.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "steampipe.labels" -}}
helm.sh/chart: {{ include "steampipe.chart" . }}
{{ include "steampipe.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "steampipe.selectorLabels" -}}
app.kubernetes.io/name: {{ include "steampipe.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "steampipe.serviceAccountName" -}}
{{- if .Values.steampipe.serviceAccount.create }}
{{- default (include "steampipe.fullname" .) .Values.steampipe.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.steampipe.serviceAccount.name }}
{{- end }}
{{- end }}
