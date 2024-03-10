package kubernetes

import (
	"strings"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/strimzi/resources"
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

#AddCluster: v1.#Transformer & {
	traits.#Kafka
	$metadata: _
	$dependencies: [...string]

	kafka: _
	k8s: {
		namespace: string
		...
	}
	config: {
		standaloneControllers: bool | *false
		storage: {
			type:        *"jbod" | "ephemeral"
			deleteClaim: bool | *false
		}
	}

	$resources: {
		if config.standaloneControllers {
			"\($metadata.id)-controllers-node-pool": resources.#KafkaNodePool & {
				#KubernetesResource
				metadata: {
					name:      "\($metadata.id)-controllers"
					namespace: k8s.namespace
					labels: {
						"strimzi.io/cluster": $metadata.id
					}
				}
				spec: {
					replicas: kafka.controllers.count
					roles: ["controller"]
					storage: {
						type: config.storage.type
						volumes: [
							{
								id:          0
								type:        "persistent-claim"
								size:        "\(kafka.controllers.sizeGB)Gi"
								deleteClaim: config.storage.deleteClaim
							},
						]
					}
				}
			}
		}
		"\($metadata.id)-node-pool": resources.#KafkaNodePool & {
			#KubernetesResource
			metadata: {
				name:      "\($metadata.id)-brokers"
				namespace: k8s.namespace
				labels: {
					"strimzi.io/cluster": $metadata.id
				}
			}
			spec: {
				replicas: kafka.brokers.count
				if config.standaloneControllers {
					roles: ["broker"]
				}
				if !config.standaloneControllers {
					roles: ["controller", "broker"]
				}
				storage: {
					type: config.storage.type
					volumes: [
						{
							id:          0
							type:        "persistent-claim"
							size:        "\(kafka.brokers.sizeGB)Gi"
							deleteClaim: config.storage.deleteClaim
						},
					]
				}
			}
		}
		"\($metadata.id)-cluster": resources.#KafkaCluster & {
			#KubernetesResource
			metadata: {
				name:      $metadata.id
				namespace: k8s.namespace
			}
			spec: {
				"kafka": {
					replicas:        kafka.replicas.count
					version:         kafka.version
					metadataVersion: "3.6-IV2"
					listeners: [
						{
							name: "plain"
							type: "internal"
							tls:  false
							port: 9092
						},
						{
							name: "tls"
							type: "internal"
							tls:  true
							port: 9093
						},
					]
					"config": {
						"offsets.topic.replication.factor":         kafka.replicas.count
						"transaction.state.log.replication.factor": kafka.replicas.count
						"transaction.state.log.min.isr":            kafka.replicas.count - 1
						"default.replication.factor":               kafka.replicas.count
						"min.insync.replicas":                      kafka.replicas.count - 1
					}
					storage: {
						type: config.storage.type
						volumes: [
							{
								id:          0
								type:        "persistent-claim"
								size:        "\(kafka.replicas.sizeGB)Gi"
								deleteClaim: config.storage.deleteClaim
							},
						]
					}
				}
				zookeeper: {
					replicas: 3
					storage: {
						type:        "persistent-claim"
						size:        "5Gi"
						deleteClaim: true
					}
				}
				entityOperator: {
					userOperator: {}
				}
			}

		}
	}
}
