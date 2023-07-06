package kubernetes

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
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
		storeRef: {
			name: string
			kind: *"SecretStore" | "ClusterSecretStore"
		}
		decodingStrategy: *"None" | "Base64" | "Base64URL" | "Auto"
	}

	$resources: "\($metadata.id)-external-secret": resources.#ExternalSecret & {
		metadata: {
			name:      $metadata.id
			namespace: k8s.namespace
		}
		spec: {
			refreshInterval: externalSecret.refreshInterval
			secretStoreRef: {
				name: externalSecret.storeRef.name
				kind: externalSecret.storeRef.kind
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
