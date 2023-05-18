package k8s

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddKubernetesResources: v1.#Transformer & {
	traits.#KubernetesResources
	$metadata:    _
	k8sResources: _
	$resources: terraform: schema.#Terraform & {
		for name, resource in k8sResources {
			"resource": kubernetes_manifest: "\($metadata.id)_\(name)": manifest: {
				resource
			}
		}
	}
}
