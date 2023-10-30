package components

import (
	k8sr "stakpak.dev/devx/k8s"
	"stakpak.dev/devx/v1/traits"
)

#TriggerAuthentication: {
	traits.#KubernetesResources

	k8s: {
		namespace: string
		...
	}
	auth: {
		name: string
		params: [...{
			parameter:  string
			secretName: string
			key:        string
		}]
	}
	k8sResources: "trigger-authentication-\(auth.name)": {
		k8sr.#KubernetesResource
		apiVersion: "keda.sh/v1alpha1"
		kind:       "TriggerAuthentication"
		metadata: {
			name:      auth.name
			namespace: k8s.namespace
		}
		spec: {
			secretTargetRef: [
				for param in auth.params {
					{
						parameter: param.parameter
						name:      param.secretName
						key:       param.key
					}
				},
			]
		}
	}
}
