package loki

#KubeVersion: [=~"^6\\.16\\.0"]: minor: >=21
#Values: [=~"^6\\.16\\.0"]: {

    // Loki settings
    loki: {
      enabled: bool | *true
      isDefault: bool | *true
      // url: string | *"http://{{(include \"loki.serviceName\" .)}}:{{ .Values.loki.service.port }}"
      readinessProbe: {
        httpGet: {
          path: string | *"/ready"
          port: string | *"http-metrics"
        }
        initialDelaySeconds: int | *45
      }
      livenessProbe: {
        httpGet: {
          path: string | *"/ready"
          port: string | *"http-metrics"
        }
        initialDelaySeconds: int | *45
      }
      datasource: {
        jsonData: string | *"{}"
        uid: string | *""
      }
    }

    // Promtail settings
    promtail: {
      enabled: bool | *true
      config: {
        logLevel: string | *"info"
        serverPort: int | *3101
        // clients: [{
        //   url: string | *"http://{{ .Release.Name }}:3100/loki/api/v1/push"
        // }]
      }
    }
}