package stacks

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/k8s/services/grafana"
)

ObservabilityStack: v1.#Stack & {
	$metadata: stack: "ObservabilityStack"
	components: {
        "grafana": grafana.#GrafanaChart & {
			helm: {
				version: "8.5.2"
				release: "grafana"
				values: {
					// Image settings
					image: {
						repository: "grafana/grafana"
						tag:        "8.5.1"
						pullPolicy: "IfNotPresent"
					}

					// Admin user configuration
					adminUser:     "admin"
					adminPassword: "admin"
					existingSecret: ""

					// Service settings
					service: {
						type: "ClusterIP"
						port: 3000
					}

					// Persistence settings
					persistence: {
						enabled:       true
						size:          "10Gi"
						storageClass:  ""
						accessMode:    "ReadWriteOnce"
						existingClaim: ""
					}

					// Probes
					livenessProbe: {
						enabled:             true
						initialDelaySeconds: 300
						periodSeconds:       1
						timeoutSeconds:      5
						failureThreshold:    3
						successThreshold:    1
					}
					readinessProbe: {
						enabled:             true
						initialDelaySeconds: 30
						periodSeconds:       10
						timeoutSeconds:      1
						failureThreshold:    3
						successThreshold:    1
					}

					// Ingress settings
					ingress: {
						enabled:     false
						annotations: {}
						hosts:       "grafana.local"
						tls:         false
					}

					// Resources
					resources: {}

					// Dashboard provisioning
					dashboards: {
						enabled:            true
						defaultFolderName:  "grafana-dashboards"
						dashboardProviders: [{
							name:                "default"
							orgId:               1
							folder:              ""
							type:                "file"
							disableDeletion:     false
							editable:            true
							updateIntervalSeconds: 10
							options: {
								path: "/var/lib/grafana/dashboards"
							}
						}]
					}

					// Datasource provisioning
					datasources: {
						enabled: true
						datasources: [{
							name:      "Prometheus"
							type:      "prometheus"
							url:       "http://prometheus:9090"
							access:    "proxy"
							isDefault: true
						}]
					}

					// Pod scheduling and annotations
					affinity:      {}
					nodeSelector:  {}
					tolerations:   []
					podAnnotations: {}
					extraVolumes:   []
					extraVolumeMounts: []
				}
            }
        }
    }
}
