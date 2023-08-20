package certm

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#CertManagerChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://charts.jetstack.io"
		chart:    "cert-manager"

		version: string | *"1.12.0"

		namespace: string | *"cert-manager"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
