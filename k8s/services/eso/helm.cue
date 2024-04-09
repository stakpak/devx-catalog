package eso

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#ExternalSecretsOperatorChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://external-secrets.io"
		chart:    "external-secrets"

		version: string | *"0.9.14"

		namespace: string | *"external-secrets"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
