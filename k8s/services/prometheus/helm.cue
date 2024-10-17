package prometheus

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#PrometheusChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://prometheus-community.github.io/helm-charts"
		chart:    "prometheus"

		version: string | *"25.26.0"

		namespace: string | *"monitoring"
		release:   string 

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}