package longhorn

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

#LonghornChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://longhorn.io/"
		chart:    "longhorn"

		version: string | *"1.4.2"

		namespace: string | *"longhorn-system"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
