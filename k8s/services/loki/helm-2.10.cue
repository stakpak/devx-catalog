package loki

#KubeVersion: [=~"^2\\.10\\.2"]: minor: >=21
#Values: [=~"^2\\.10\\.2"]: {

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

    // Grafana settings
    grafana: {
      enabled: bool | *true
      sidecar: {
        datasources: {
          label: string | *""
          labelValue: string | *""
          enabled: bool | *true
          maxLines: int | *1000
        }
      }
      image: {
        tag: string | *"10.3.3"
      }
      adminUser: string | *"grafana"
      adminPassword: string | *"grafana"
    }

    // Prometheus settings
    prometheus: {
      enabled: bool | *true
      isDefault: bool | *true
      // url: string | *"http://{{ include \"prometheus.fullname\" .}}:{{ .Values.prometheus.server.service.servicePort }}{{ .Values.prometheus.server.prefixURL }}"
      datasource: {
        jsonData: string | *"{}"
      }
    }
}