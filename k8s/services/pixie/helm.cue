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
		url:      "https://helm-charts.newrelic.com"
		chart:    "newrelic-pixie"

		version: string | *"2.1.6"

		namespace: string | *"monitoring"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}