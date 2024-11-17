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
				version: string | *"2.10.2"
				release: "loki"
				values: {}
            }
        }
        "grafana": grafana.#GrafanaChart & {
			helm: {
				version: string | *"8.5.11"
				release: "grafana"
				values: {}
            }
        }
        "prometheus": prometheus.#PrometheusChart & {
			helm: {
				version: string | *"25.26.0"
				release: "prometheus"
				values: {}
            }
        }
		"pixie": pixie.#PixieChart & {
			helm: {
				version: string | *"0.1.6"
				release: "pixie"
				values: {}
			}
		}
    }
}