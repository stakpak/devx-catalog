package resources

import (
	"strings"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

#KubernetesResource: {
	metadata?: metav1.#ObjectMeta
	$metadata: labels: {
		driver: "kubernetes"
		type:   "\(apiVersion)/\(strings.ToLower(kind))"
		...
	}
	...
	apiVersion: string
	kind:       string
}

#ScaledObject: {
	#KubernetesResource
	apiVersion: "keda.sh/v1alpha1"
	kind:       "ScaledObject"
}