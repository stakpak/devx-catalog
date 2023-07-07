package ingressnginx

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#IngressNginxChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://kubernetes.github.io/ingress-nginx"
		chart:    "ingress-nginx"

		version: string | *"4.0.5"

		namespace: string | *"ingress-nginx"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
