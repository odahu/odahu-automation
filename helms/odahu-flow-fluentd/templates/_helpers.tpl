{{/* vim: set filetype=mustache: */}}

{{/*
----------- VERSIONING -----------
*/}}

{{/*
Function builds application (not HELM) version string
This section is under control by .fluentdVersion section
By default value from $.Chart.AppVersion is used
Arguments:
    - . - root HELM scope
*/}}
{{- define "fluentd.application-version" -}}
{{ default .Chart.AppVersion .Values.fluentdVersion }}
{{- end -}}

{{/*
Function builds default labels for all components
It section uses "fluentd.application-version"
Arguments:
    - . - root HELM scope
*/}}
{{- define "fluentd.helm-labels" -}}
app.kubernetes.io/component: {{ .component | quote }}
app.kubernetes.io/version: "{{ include "fluentd.application-version" .root }}"
app: {{ .component | quote }}
version: "{{ include "fluentd.application-version" .root }}"
app.kubernetes.io/instance: {{ .root.Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .root.Release.Service | quote }}
app.kubernetes.io/name: "fluentd"
helm.sh/chart: "{{ .root.Chart.Name }}-{{ .root.Chart.Version }}"
{{- end -}}

{{/*
Function builds additional search labels
Arguments:
    - . - root HELM scope
*/}}
{{- define "fluentd.helm-labels-for-search" -}}
app.kubernetes.io/component: {{ .component | quote }}
app: {{ .component | quote }}
app.kubernetes.io/instance: {{ .root.Release.Name | quote }}
{{- end -}}

{{/*
----------- IMAGES -----------
*/}}
{{/*
Function builds default image name for Kubernetes Pod
Arguments:
    - .root - root HELM scope
    - .tpl - template for building default URI of image
*/}}
{{- define "fluentd.default-image-name" -}}
{{ printf .tpl .root.Values.imagesRegistry (include "fluentd.application-version" .root) }}
{{- end -}}

{{/*
Function builds image name for Kubernetes Pod
Arguments:
    - .root - root HELM scope
    - .service - service's scope with desired image field
    - .tpl - template for building default URI of image
*/}}
{{- define "fluentd.image-name" -}}
{{- if .service }}
{{- if (hasKey .service "image") }}
{{ .service.image  }}
{{- else -}}
{{- include "fluentd.default-image-name" . -}}
{{ end }}
{{- else }}
{{- include "fluentd.default-image-name" . -}}
{{ end }}
{{- end -}}