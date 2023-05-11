package argocd

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

#ArgoCDChart: {
	traits.#Helm
	helm: {
		repoType: "default"
		url:      "https://argoproj.github.io/argo-helm"
		chart:    "argo-cd"

		version: string | *"4.5.11"

		namespace: string | *"argo-cd"
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
