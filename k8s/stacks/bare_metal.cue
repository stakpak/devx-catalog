package stacks

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/k8s/services/longhorn"
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
