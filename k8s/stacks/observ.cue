package stacks

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/k8s/services/grafana"
)

ObservabilityStack: v1.#Stack & {
	$metadata: stack: "ObservabilityStack"
	components: {
        grafana: grafana.#Grafana & {
			helm: {
				version: "8.5.2"
				release: "grafana"
				values: {}
            }
        }
    }
}