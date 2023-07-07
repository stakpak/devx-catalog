package mongodb

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#MongoDBChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://mongodb.github.io/helm-charts"
		chart:    "community-operator"

		version: string | *"0.8.0"

		namespace: string | *"mongodb"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}

#MongoCRDChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://mongodb.github.io/helm-charts"
		chart:    "community-operator-crds"

		version: string | *"0.8.0"

		namespace: string | *"mongodb"
		release:   string

		values: {}
	}
}
