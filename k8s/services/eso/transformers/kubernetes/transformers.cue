package kubernetes

import (
	"strings"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	resources "stakpak.dev/devx/k8s/services/eso/resources"
)

#KubernetesResource: {
	$metadata: labels: {
		driver: "kubernetes"
		type:   "\(apiVersion)/\(strings.ToLower(kind))"
		...
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
			"\(secret.name)": {
				data: secret
				properties: {
					if secret.property != _|_ {
						"\(secret.property)": null
					}
				}
				"template": secret.template
			}
		}
	}

	$resources: {
		for secretName, obj in secretObjs {
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

					if obj.template == _|_ {
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

					if obj.template != _|_ {
						target: template: {
							engineVersion: "v2"
							data: {
								value: obj.template.value
							}
						}
						data: [
							for propertyName, propertyObj in obj.template.properties {
								secretKey: propertyName
								remoteRef: {
									key:     propertyObj.name
									version: obj.data.version | *"latest"
									if propertyObj.property != _|_ {
										property: propertyObj.property
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
}

#AddImagePullSecret: v1.#Transformer & {
	traits.#ImagePullSecret
	$metadata: _
	secret:    _

	k8s: {
		namespace: string
		...
	}
	externalSecret: {
		refreshInterval: *"1h" | string
	}

	$resources: {
		if secret.provider == "aws" {
			"\($metadata.id)-authorization-token": resources.#ECRAuthorizationToken & {
				#KubernetesResource
				metadata: {
					name:      "\($metadata.id)-authorization-token"
					namespace: k8s.namespace
				}
				spec: {
					region: secret.region
					auth: secretRef: {
						accessKeyIDSecretRef: {
							name: secret.accessKey.name
							key:  secret.accessKey.key
						}
						secretAccessKeySecretRef: {
							name: secret.secretAccessKey.name
							key:  secret.secretAccessKey.key
						}
					}
				}
			}
			"\($metadata.id)-image-pull-secret": resources.#ExternalSecret & {
				#KubernetesResource
				metadata: {
					name:      "\($metadata.id)-image-pull-secret"
					namespace: k8s.namespace
				}
				spec: {
					refreshInterval: externalSecret.refreshInterval
					target: {
						template: {
							type: "kubernetes.io/dockerconfigjson"
							data: ".dockerconfigjson": #"{"auths":{"{{ .proxy_endpoint }}":{"username":"{{ .username }}","password":"{{ .password }}","auth":"{{ printf "%s:%s" .username .password | b64enc }}"}}}"#
						}
						name:           "\($metadata.id)-image-pull-secret"
						creationPolicy: "Owner"
					}
					dataFrom: [
						{
							sourceRef: generatorRef: {
								apiVersion: "generators.external-secrets.io/v1alpha1"
								name:       "\($metadata.id)-authorization-token"
								kind:       "ECRAuthorizationToken"
							}
						},
					]
				}
			}
		}
	}

}
