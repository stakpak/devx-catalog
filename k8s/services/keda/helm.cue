package keda

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#KEDAChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://kedacore.github.io/charts"
		chart:    "keda"

		version: string | *"4.0.5"

		namespace: string | *"keda"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
