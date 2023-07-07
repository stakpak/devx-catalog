package argocd

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#ArgoCDChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://argoproj.github.io/argo-helm"
		chart:    "argo-cd"

		version: string | *"4.5.11"

		namespace: string | *"argo-cd"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
