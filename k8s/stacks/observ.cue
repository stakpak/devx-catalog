package stacks

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/k8s/services/loki"
)

ObservabilityStack: v1.#Stack & {
	$metadata: stack: "ObservabilityStack"
	components: {
        "grafana": loki.#LokiChart & {
			helm: {
				version: "2.10.2"
				release: "loki"
				values: {}
            }
        }
    }
}