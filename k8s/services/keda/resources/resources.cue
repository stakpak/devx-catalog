package resources

import "strings"

#KubernetesResource: {
	$metadata: labels: {
		driver: "kubernetes"
		type:   "\(apiVersion)/\(strings.ToLower(kind))"
		...
	}
	apiVersion: string
	kind:       string
}

#ScaledObject: {
	#KubernetesResource
	apiVersion: "keda.sh/v1alpha1"
	kind:       "ScaledObject"
}