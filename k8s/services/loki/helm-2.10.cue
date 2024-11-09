package loki

import (
	"k8s.io/api/core/v1"
	// "stakpak.dev/devx/k8s"
)

#KubeVersion: [=~"^2\\.10\\.2"]: minor: >=21
#Values: [=~"^2\\.10\\.2"]: {
{
    test_pod: {
        enabled: true
        image: "bats/bats:1.8.2"
        pullPolicy: v1.#imagePullPolicy | *"IfNotPresent"
    }

    loki: {
        enabled: true
        isDefault: true
        url: "http://{{(include \"loki.serviceName\" .)}}:{{ .Values.loki.service.port }}"
        readinessProbe: {
            httpGet: {
                path: "/ready"
                port: "http-metrics"
            }
            initialDelaySeconds: 45
        }
        livenessProbe: {
            httpGet: {
                path: "/ready"
                port: "http-metrics"
            }
            initialDelaySeconds: 45
        }
        datasource: {
            jsonData: "{}"
            uid: ""
        }
    }

    promtail: {
        enabled: true
        config: {
            logLevel: "info"
            serverPort: 3101
            clients: [{
                url: "http://{{ .Release.Name }}:3100/loki/api/v1/push"
            }]
        }
    }

    fluent_bit: {
        enabled: false
    }

    grafana: {
        enabled: false
        sidecar: {
            datasources: {
                label: ""
                labelValue: ""
                enabled: true
                maxLines: 1000
            }
        }
        image: {
            tag: "10.3.3"
        }
    }

    prometheus: {
        enabled: false
        isDefault: false
        url: "http://{{ include \"prometheus.fullname\" .}}:{{ .Values.prometheus.server.service.servicePort }}{{ .Values.prometheus.server.prefixURL }}"
        datasource: {
            jsonData: "{}"
        }
    }

    filebeat: {
        enabled: false
        filebeatConfig: {
            "filebeat.yml": '''
                # logging.level: debug
                filebeat.inputs:
                - type: container
                  paths:
                    - /var/log/containers/*.log
                  processors:
                  - add_kubernetes_metadata:
                      host: ${NODE_NAME}
                      matchers:
                      - logs_path:
                          logs_path: "/var/log/containers/"
                output.logstash:
                  hosts: ["logstash-loki:5044"]
            '''
        }
    }

    logstash: {
        enabled: false
        image: "grafana/logstash-output-loki"
        imageTag: "1.0.1"
        filters: {
            main: '''
                filter {
                    if [kubernetes] {
                        mutate {
                            add_field => {
                                "container_name" => "%{[kubernetes][container][name]}"
                                "namespace" => "%{[kubernetes][namespace]}"
                                "pod" => "%{[kubernetes][pod][name]}"
                            }
                            replace => { "host" => "%{[kubernetes][node][name]}" }
                        }
                    }
                    mutate {
                        remove_field => ["tags"]
                    }
                }
            '''
        }
        outputs: {
            main: '''
                output {
                    loki {
                        url => "http://loki:3100/loki/api/v1/push"
                        #username => "test"
                        #password => "test"
                    }
                    # stdout { codec => rubydebug }
                }
            '''
        }
    }

    proxy: {
        http_proxy: ""
        https_proxy: ""
        no_proxy: ""
    }
}
}