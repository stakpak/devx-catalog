package k8s

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
	resources "stakpak.dev/devx/k8s/services/eso/resources"
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
			kind: *"ClusterSecretStore" | "SecretStore"
		}
		decodingStrategy: *"None" | "Base64" | "Base64URL" | "Auto"
	}

	let secretObjs = {
		for _, secret in secrets {
			"\(secret.name)": {
				data: secret
				properties: {
					if secret.property != _|_ {
						"\(secret.property)": null
					}
				}
			}
		}
	}

	$resources: terraform: schema.#Terraform & {
		resource: kubernetes_manifest: {
			for secretName, obj in secretObjs {
				"\(secretName)_external_secret": manifest: resources.#ExternalSecret & {
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

						if len(obj.properties) == 0 {
							data: [{
								secretKey: "value"
								remoteRef: {
									key:              secretName
									version:          obj.data.version | *"latest"
									decodingStrategy: externalSecret.decodingStrategy
								}
							}]
						}

						if len(obj.properties) > 0 {
							data: [
								for propertyName, _ in obj.properties {
									secretKey: propertyName
									remoteRef: {
										key:              secretName
										version:          obj.data.version | *"latest"
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
}
