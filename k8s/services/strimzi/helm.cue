package strimzi

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#StrimziChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "oci"
		url:      "oci://quay.io/strimzi-helm"
		chart:    "strimzi-kafka-operator"

		version: string | *"0.39.0"

		namespace: string | *"kafka"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
