package simplemongodb

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#SimpleMongoDBChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "oci"
		url:      "registry-1.docker.io/bitnamicharts"
		chart:    "mongodb"

		version: string | *"13.17.1"

		namespace: string | *"mongodb"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
