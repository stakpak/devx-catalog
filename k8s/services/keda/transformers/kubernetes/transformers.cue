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
			triggers: [
				for trigger in triggers {
					type: trigger.type
					metadata: {
						value: trigger.metadata.value
						if trigger.type == "cpu" || trigger.type == "memory" {
							metricType: trigger.metricType
							if trigger.metadata.containerName != _|_ {
								containerName: trigger.metadata.containerName
							}
						}
						if trigger.type == "rabbitmq" {
							queueName: trigger.metadata.queueName
							mode:      trigger.metadata.mode
							if trigger.metadata.host != _|_ {
								host: trigger.metadata.host
							}
							if trigger.metadata.protocol != _|_ {
								protocol: trigger.metadata.protocol
							}
							if trigger.metadata.activationValue != _|_ {
								activationValue: trigger.metadata.activationValue
							}
							if trigger.metadata.vhostName != _|_ {
								vhostName: trigger.metadata.vhostName
							}
							if trigger.metadata.hostFromEnv != _|_ {
								hostFromEnv: trigger.metadata.hostFromEnv
							}
							if trigger.metadata.authenticationRef != _|_ {
								authenticationRef: {
									name: trigger.metadata.authenticationRef.name
								}
							}
						}
					}
				},
			]
		}
	}
}
