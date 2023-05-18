package resources

import (
	"guku.io/devx/k8s"
	"github.com/external-secrets/external-secrets/apis/externalsecrets/v1beta1"
)

#ClusterSecretStore: {
	k8s.#KubernetesResource
	v1beta1.#ClusterSecretStore
	apiVersion: "external-secrets.io/v1beta1"
	kind:       "ClusterSecretStore"
	spec: {
		controller:      string | *""
		refreshInterval: uint | *0
	}
}
#ClusterExternalSecret: {
	k8s.#KubernetesResource
	v1beta1.#ClusterExternalSecret
	apiVersion: "external-secrets.io/v1beta1"
	kind:       "ClusterExternalSecret"
}

#SecretStore: {
	k8s.#KubernetesResource
	v1beta1.#SecretStore
	apiVersion: "external-secrets.io/v1beta1"
	kind:       "SecretStore"
	metadata: namespace!: string
	spec: {
		controller:      string | *""
		refreshInterval: uint | *0
	}
}
#ExternalSecret: {
	k8s.#KubernetesResource
	v1beta1.#ExternalSecret
	apiVersion: "external-secrets.io/v1beta1"
	kind:       "ExternalSecret"
	metadata: namespace!: string
}
