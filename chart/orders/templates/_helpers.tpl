{{- define "messageHubEnv" -}}
  {{- if .Values.messagehub.binding.name -}}
        - name: messagehub
          valueFrom:
            secretKeyRef:
              name: {{ .Values.messagehub.binding.name | lower | replace " " "-" | nospace }}
              key: binding
  {{- end -}}
{{- end -}}

{{- define "mysqlBindingName" -}}
  {{- .Values.mysql.binding.name -}}
{{- end -}}

{{- define "hs256SecretName" -}}
  {{- if .Values.global.hs256key.secretName -}}
    {{- .Release.Name }}-{{ .Values.global.hs256key.secretName -}}
  {{- else -}}
    {{- .Release.Name }}-{{ .Chart.Name }}-{{ .Values.hs256key.secretName -}}
  {{- end }}
{{- end -}}

{{- define "ordersDockerImage" -}}
  {{- .Values.image.repository }}
{{- end -}}

{{- define "dataLoaderDockerImage" -}}
  {{- .Values.dataloader.image.repository }}
{{- end -}}
