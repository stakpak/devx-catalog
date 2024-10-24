package stacks

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/k8s/services/loki"
	"stakpak.dev/devx/k8s/services/grafana"
	"stakpak.dev/devx/k8s/services/prometheus"
)

ObservabilityStack: v1.#Stack & {
	$metadata: stack: "ObservabilityStack"
	components: {
        "loki": loki.#LokiChart & {
			helm: {
				version: "6.16.0"
				release: "loki"
				values: {}
            }
        }
        "grafana": grafana.#GrafanaChart & {
			helm: {
				version: "8.5.1"
				release: "grafana"
				values: {}
            }
        }
        "prometheus": prometheus.#PrometheusChart & {
			helm: {
				version: "25.26.0"
				release: "prometheus"
				values: {}
            }
        }
    }
}