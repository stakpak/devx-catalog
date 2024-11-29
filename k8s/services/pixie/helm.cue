package pixie

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#PixieChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://pixie-operator-charts.storage.googleapis.com"
		chart:    "pixie-operator-chart"

		version: string | *"0.1.6"

		namespace: "pl"
		release:   string | *"pixie"

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}