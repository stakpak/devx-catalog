package rabbitmq

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#RabbitMQOperatorChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "oci"
		url:      "oci://registry-1.docker.io/bitnamicharts"
		chart:    "rabbitmq-cluster-operator"

		version: string | *"3.4.1"

		namespace: string | *"rabbitmq"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
