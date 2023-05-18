package stacks

import (
	"guku.io/devx/v1"
	"guku.io/devx/k8s/services/longhorn"
)

KubernetesBareMetalStack: v1.#Stack & {
	$metadata: stack: "KubernetesBareMetalStack"
	components: {
		"longhorn": longhorn.#LonghornChart & {
			helm: {
				version: "1.4.2"
				release: "longhorn"
				values: {}
			}
		}
	}
}
