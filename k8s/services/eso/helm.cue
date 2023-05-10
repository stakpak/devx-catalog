package eso

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

#ExternalSecretsOperatorChart: {
	traits.#Helm
	helm: {
		repoType: "default"
		url:      "https://charts.external-secrets.io"
		chart:    "external-secrets"

		version: string | *"0.6.0"

		namespace: string | *"external-secrets"
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
