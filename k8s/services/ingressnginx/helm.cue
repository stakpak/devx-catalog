package ingressnginx

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

#IngressNginxChart: {
	traits.#Helm
	helm: {
		repoType: "default"
		url:      "https://kubernetes.github.io/ingress-nginx"
		chart:    "ingress-nginx"

		version: string | *"4.0.5"

		namespace: string | *"ingress-nginx"
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
