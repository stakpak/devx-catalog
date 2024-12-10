package components

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/eso/resources"
)


#AWSSecretStore: {
	traits.#KubernetesResources

	k8s: {
		namespace: string
		...
	}
	aws: {
		region: string
		...
	}
	secretStore: {
		name:             string
		scope:            "cluster" | "namespace"
		type:             "ParameterStore" | "SecretsManager"
		role?:            string
		accessKeySecret?: string | v1.#Secret
	}

	if secretStore.scope == "cluster" {
		k8sResources: "secret-store-\(secretStore.name)": resources.#ClusterSecretStore
	}
	if secretStore.scope == "namespace" {
		k8sResources: "secret-store-\(secretStore.name)": resources.#SecretStore & {
			metadata: namespace: k8s.namespace
		}
	}
	k8sResources: "secret-store-\(secretStore.name)": {
		metadata: name: secretStore.name
		spec: provider: "aws": {
			service: secretStore.type
			region:  aws.region
			if secretStore.role != _|_ {
				role: secretStore.role
			}
			if (secretStore.accessKeySecret & v1.#Secret) != _|_ {
				auth: secretRef: {
					accessKeyIDSecretRef: {
						namespace: k8s.namespace
						name:      secretStore.accessKeySecret.name
						key:       "access-key"
					}
					secretAccessKeySecretRef: {
						namespace: k8s.namespace
						name:      secretStore.accessKeySecret.name
						key:       "secret-access-key"
					}
				}
			}
		}
	}
}

#KubernetesSecretStore: {
	traits.#KubernetesResources

	k8s: {
		namespace: string
		...
	}

	secretStore: {
		name: string
	}

	k8sResources: {
		"secret-store-\(secretStore.name)-role": {
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "Role"
			metadata: {
				name:      "secret-store-\(secretStore.name)-role"
				namespace: k8s.namespace
			}
			rules: [
				{
					apiGroups: [""]
					resources: ["secrets"]
					verbs: ["get", "list", "watch"]
				}, {
					apiGroups: ["authorization.k8s.io"]
					resources: ["selfsubjectrulesreviews"]
					verbs: ["create"]
				},
			]
		}
		"secret-store-\(secretStore.name)-service-account": {
			apiVersion: "v1"
			kind:       "ServiceAccount"
			metadata: {
				name:      "secret-store-\(secretStore.name)-service-account"
				namespace: k8s.namespace
			}
		}
		"secret-store-\(secretStore.name)-rolebinding": {
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "RoleBinding"
			metadata: {
				name:      "secret-store-\(secretStore.name)-rolebinding"
				namespace: k8s.namespace
			}
			subjects: [
				{
					kind:      "ServiceAccount"
					name:      "secret-store-\(secretStore.name)-service-account"
					namespace: k8s.namespace
				},
			]
			roleRef: {
				kind:     "Role"
				name:     "secret-store-\(secretStore.name)-role"
				apiGroup: "rbac.authorization.k8s.io"
			}
		}
		"secret-store-\(secretStore.name)": {
			apiVersion: "external-secrets.io/v1beta1"
			kind:       "SecretStore"
			metadata: {
				name:      secretStore.name
				namespace: k8s.namespace
			}
			spec: provider: "kubernetes": {
				remoteNamespace: k8s.namespace
				server: caProvider: {
					type: "ConfigMap"
					name: "kube-root-ca.crt"
					key:  "ca.crt"
				}
				auth: serviceAccount: name: "secret-store-\(secretStore.name)-service-account"
			}
		}
	}
}
