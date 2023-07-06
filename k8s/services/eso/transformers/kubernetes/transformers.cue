package kubernetes

import (
	"strings"
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	resources "guku.io/devx/k8s/services/eso/resources"
)

#KubernetesResource: {
	$metadata: labels: {
		driver: "kubernetes"
		type:   "\(apiVersion)/\(strings.ToLower(kind))"
	}
	apiVersion: string
	kind:       string
}

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
			kind: *"ClusterSecretStore" | "SecretStore"
		}
		decodingStrategy: *"None" | "Base64" | "Base64URL" | "Auto"
	}

	let secretObjs = {
		for _, secret in secrets {
			data: secret
			properties: "\(secret.name)": {
				if secret.property != _|_ {
					"\(secret.property)": null
				}
			}
		}
	}

	$resources: {
		for secretName, secret in secretObjs {
			"\(secretName)-external-secret": resources.#ExternalSecret & {
				#KubernetesResource
				metadata: {
					name:      secretName
					namespace: k8s.namespace
				}
				spec: {
					refreshInterval: externalSecret.refreshInterval
					secretStoreRef: {
						name: externalSecret.storeRef.name
						kind: externalSecret.storeRef.kind
					}

					if len(secret.properties) == 0 {
						data: [{
							secretKey: "value"
							remoteRef: {
								key:              secretName
								version:          secret.data.version | *"latest"
								decodingStrategy: externalSecret.decodingStrategy
							}
						}]
					}

					if len(secret.properties) > 0 {
						data: [
							for propertyName, _ in secret.properties {
								secretKey: propertyName
								remoteRef: {
									key:              secretName
									version:          secret.data.version | *"latest"
									property:         propertyName
									decodingStrategy: externalSecret.decodingStrategy
								}
							},
						]
					}
				}
			}
		}
	}
}
