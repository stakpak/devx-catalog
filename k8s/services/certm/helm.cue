package certm

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

#CertManagerChart: {
	traits.#Helm
	helm: {
		repoType: "default"
		url:      "https://charts.jetstack.io"
		chart:    "cert-manager"

		version: string | *"1.8.0"

		namespace: string | *"cert-manager"
		release:   string

		k8s: "version": (v1.getMatch & {
			match: version
			input: #KubeVersion
		}).result
		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
