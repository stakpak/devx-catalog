package k8s

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
	resources "guku.io/devx/k8s/services/eso/resources"
)

#AddExternalSecret: v1.#Transformer & {
	traits.#Secret
	$metadata: _
	secrets:   _

	k8s: {
		namespace: string
		...
	}

	$resources: terraform: schema.#Terraform & {
		resource: kubernetes_manifest: "\($metadata.id)-secret-store": {
			manifest: resources.#ExternalSecret & {
				metadata: {
					name:      $metadata.id
					namespace: k8s.namespace
				}
				spec: {
					refreshInterval: *"1h" | string
					secretStoreRef: {
						name: string
						kind: *"SecretStore" | string
					}
					data: [
						for _, secret in secrets {
                            secretKey: secret.name
                            remoteRef: {
                                key: secret.name
                                version: secret.version | *"latest"
                            }
						},
					]
				}
			}
		}
	}
}
