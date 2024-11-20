package stacks

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/k8s/services/loki"
	"stakpak.dev/devx/k8s/services/grafana"
	"stakpak.dev/devx/k8s/services/prometheus"
	"stakpak.dev/devx/k8s/services/pixie"
)

FullObservabilityStack: v1.#Stack & {
	$metadata: stack: "FullObservabilityStack"
	components: {
        "loki": loki.#LokiChart & {
			helm: {
				release: "loki"
				values: {}
            }
        }
        "grafana": grafana.#GrafanaChart & {
			helm: {
				release: "grafana"
				values: {}
            }
        }
        "prometheus": prometheus.#PrometheusChart & {
			helm: {
				release: "prometheus"
				values: {}
            }
        }
		"pixie": pixie.#PixieChart & {
			helm: {
				release: "pixie"
				values: {}
			}
		}
    }
}