package kubernetes

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/keda/resources"
)

#AddScaledObject: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	traits.#Scalable

	$metadata: _
	scale:     _
	triggers: [... resources.#CPUTrigger | resources.#MemoryTrigger | resources.#RabbitMQTrigger]
	
	appName: string | *$metadata.id
	$resources: "\(appName)-scaled-object": {
		resources.#ScaledObject
		metadata: {
			name: appName
		}
		spec: {
			scaleTargetRef: {
				name:       $resources["\(appName)-deployment"].metadata.name
				kind:       $resources["\(appName)-deployment"].kind
				apiVersion: $resources["\(appName)-deployment"].apiVersion
			}
			pollingInterval:  scale.intervals.pollingInterval
			cooldownPeriod:   scale.intervals.cooldownPeriod
			idleReplicaCount: scale.replicas.idle
			minReplicaCount:  scale.replicas.min
			maxReplicaCount:  scale.replicas.max
			if scale.fallback != _|_ {
				fallback: {
					failureThreshold: fallback.failureThreshold
					replicas:         fallback.replicas
				}
			}
			"triggers": triggers
		}
	}
}
