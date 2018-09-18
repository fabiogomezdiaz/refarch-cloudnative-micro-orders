{{- define "orders.fullname" -}}
  {{- .Release.Name }}-{{ .Chart.Name -}}
{{- end -}}

{{/* MySQL Init Container Template */}}
{{- define "orders.labels" }}
app: bluecompute
micro: orders
tier: backend
heritage: {{ .Release.Service | quote }}
release: {{ .Release.Name | quote }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/* MySQL Init Container Template */}}
{{- define "orders.mariadb.initcontainer" }}
- name: test-mysql
  image: {{ .Values.mysql.image }}:{{ .Values.mysql.imageTag }}
  imagePullPolicy: {{ .Values.mysql.imagePullPolicy }}
  command:
  - "/bin/bash"
  - "-c"
  {{- if .Values.mariadb.db.password }}
  - "until mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e status; do echo waiting for mysql; sleep 1; done"
  {{- else }}
  - "until mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u${MYSQL_USER} -e status; do echo waiting for mysql; sleep 1; done"
  {{- end }}
  env:
  {{- include "orders.mariadb.environmentvariables" . | indent 2 }}
{{- end }}

{{/* Orders MySQL Environment Variables */}}
{{- define "orders.mariadb.environmentvariables" }}
- name: MYSQL_HOST
  value: {{ template "orders.mariadb.name" . }}
- name: MYSQL_PORT
  value: {{ .Values.mariadb.service.port | quote }}
- name: MYSQL_DATABASE
  value: {{ .Values.mariadb.db.name | quote }}
- name: MYSQL_USER
  value: {{ .Values.mariadb.db.user | quote }}
{{- if .Values.mariadb.db.password }}
- name: MYSQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "orders.mariadb.secret.name" . }}
      key: mariadb-password
{{- end }}
{{- end }}

{{/* MariaDB Name */}}
{{- define "orders.mariadb.name" -}}
  {{- if .Values.mariadb.enabled -}}
    {{ .Release.Name }}-{{ .Values.mariadb.nameOverride }}
  {{- else -}}
    {{ .Values.mariadb.nameOverride }}
  {{- end -}}
{{- end -}}

{{/* MariaDB Secret Name */}}
{{- define "orders.mariadb.secret.name" -}}
  {{- if .Values.mariadb.enabled -}}
    {{ .Release.Name }}-{{ .Values.mariadb.nameOverride }}
  {{- else -}}
    {{ .Values.mariadb.nameOverride }}-secret
  {{- end -}}
{{- end -}}

{{/* Orders HS256KEY Environment Variables */}}
{{- define "orders.hs256key.environmentvariables" }}
- name: HS256_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "orders.hs256key.secretName" . }}
      key:  key
{{- end }}

{{/* Orders HS256KEY Secret Name */}}
{{- define "orders.hs256key.secretName" -}}
  {{- if .Values.global.hs256key.secretName -}}
    {{ .Values.global.hs256key.secretName -}}
  {{- else if .Values.hs256key.secretName -}}
    {{ .Values.hs256key.secretName -}}
  {{- else -}}
    {{- .Release.Name }}-{{ .Chart.Name }}-hs256key
  {{- end }}
{{- end -}}