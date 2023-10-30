package kubernetes

import (
	"strings"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/keda/components"
	"stakpak.dev/devx/k8s/services/keda/resources"
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

#AddScaledObject: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	traits.#Scalable

	$metadata: _
	replicas: _
	intervals: _
	fallback: _
	triggers: [... resources.#CPUTrigger | resources.#MemoryTrigger]
	appName: string | *$metadata.id
	$resources: "\(appName)-hpa": components.#ScaledObject & {
		scaler: {
			name: appName
			pollingInterval: intervals.pollingInterval
			cooldownPeriod:  intervals.cooldownPeriod
			idleReplicaCount: replicas.idle
			minReplicaCount: replicas.min
			maxReplicaCount: replicas.max
			fallback: fallback
			target: {
				name:       $resources["\(appName)-deployment"].metadata.name
				kind:       $resources["\(appName)-deployment"].kind
				apiVersion: $resources["\(appName)-deployment"].apiVersion
			}
			triggers: triggers
		}
	}
}
