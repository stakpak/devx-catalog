package components

import (
	k8sr "stakpak.dev/devx/k8s"
	"stakpak.dev/devx/v1/traits"
)

#ScaledObject: {
	traits.#KubernetesResources

	k8s: {
		namespace: string
		...
	}
	scaler: {
		name:           string
		deploymentName: string
		trigger: [...{
			type:       "cpu" | "memory"
			metricType: "Utilization" | "AverageValue"
			metadata: {
				value:          string
				containerName?: string
			}
		} | {
			type: "rabbitmq"
			metadata: {
				queueName:        string
				protocol?:        "amqp" | "http"
				mode:             "QueueLength" | "MessageRate"
				value:            string
				activationValue?: string
				vhostName?:       string
				host?:            string
				hostFromEnv?:     string
				authenticationRef?: {
					name: string
				}
			}
		},
		]
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
				name: scaler.deploymentName
			}
			triggers: [
				for trigger in scaler.trigger {
					type: trigger.type
					metadata: {
						if trigger.type == "cpu" || trigger.type == "memory" {
							metricType: trigger.metricType
							value:      trigger.metadata.value
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
