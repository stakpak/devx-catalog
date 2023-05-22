package imagepullsecrets

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

#ImagePullSecretsChart: {
	traits.#Helm
	k8s: "version": (v1.getMatch & {
		match: helm.version
		input: #KubeVersion
	}).result
	helm: {
		repoType: "default"
		url:      "https://kubernetes-charts.banzaicloud.com"
		chart:    "banzaicloud-stable/imagepullsecrets"

		version: string | *"0.3.12"

		namespace: string | *"imagepullsecrets"
		release:   string

		values: (v1.getMatch & {
			match: version
			input: #Values
		}).result
	}
}
