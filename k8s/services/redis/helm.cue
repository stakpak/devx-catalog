package redis

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

#RedisChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "oci"
		url:      "oci://registry-1.docker.io/bitnamicharts"
		chart:    "redis"

		version: string | *"17.11.4"

		namespace: string | *"redis"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
