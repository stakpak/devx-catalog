package grafana

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#GrafanaChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://grafana.github.io/helm-charts"
		chart:    "grafana"

		version: string | *"8.5.2"

		namespace: string | *"monitoring"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}