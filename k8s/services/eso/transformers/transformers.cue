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

	externalSecret: {
		refreshInterval: *"1h" | string
		storeRef?: {
			name: string
			kind: "SecretStore" | "ClusterSecretStore"
		}
		decodingStrategy: *"None" | "Base64" | "Base64URL" | "Auto"
	}

	$resources: terraform: schema.#Terraform & {
		resource: kubernetes_manifest: "\($metadata.id)-external-secret": {
			manifest: resources.#ExternalSecret & {
				metadata: {
					name:      $metadata.id
					namespace: k8s.namespace
				}
				spec: {
					refreshInterval: externalSecret.refreshInterval
					if externalSecret.storeRef != _|_ {
						secretStoreRef: {
							name: externalSecret.storeRef.name
							kind: externalSecret.storeRef.kind
						}
					}
					data: [
						for _, secret in secrets {
							secretKey: secret.name
							remoteRef: {
								key:     secret.name
								version: secret.version | *"latest"
								if secret.property != _|_ {
									property: secret.property
								}
								decodingStrategy: externalSecret.decodingStrategy
							}
						},
					]
				}
			}
		}
	}
}
