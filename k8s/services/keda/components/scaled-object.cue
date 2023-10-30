package components

import (
	k8sr "stakpak.dev/devx/k8s"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/keda/resources"
)

#ScaledObject: {
	traits.#KubernetesResources

	k8s: {
		namespace: string
		...
	}
	scaler: {
		name: string
		target: {
			name:       string
			kind:       string
			apiVersion: string
		}
		pollingInterval:  int | *30
		cooldownPeriod:   int | *300
		idleReplicaCount: int | *0
		minReplicaCount:  int | *0
		maxReplicaCount:  int | *100
		fallback?: {
			failureThreshold: uint | *3
			replicas:         uint | *replicas.min
		}
		triggers: [... resources.#CPUTrigger | resources.#MemoryTrigger | resources.#RabbitMQTrigger]
	}

	k8sResources: "scaled-object-\(scaler.name)": {
		k8sr.#KubernetesResource
		apiVersion: "keda.sh/v1alpha1"
		kind:       "ScaledObject"
		metadata: {
			name:      scaler.name
			namespace: k8s.namespace
		}
		spec: {
			scaleTargetRef: {
				name:       scaler.target.name
				kind:       scaler.target.kind
				apiVersion: scaler.target.apiVersion
			}
			pollingInterval:  scaler.pollingInterval
			cooldownPeriod:   scaler.cooldownPeriod
			idleReplicaCount: scaler.idleReplicaCount
			minReplicaCount:  scaler.minReplicaCount
			maxReplicaCount:  scaler.maxReplicaCount
			if scaler.fallback != _|_ {
				fallback: {
					failureThreshold: scaler.fallback.failureThreshold
					replicas:         scaler.fallback.replicas
				}
			}
			triggers: [
				for trigger in scaler.triggers {
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
