package minio

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#MinioChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://charts.min.io"
		chart:    "minio"

		version: string | *"5.0.13"

		namespace: string | *"minio"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
