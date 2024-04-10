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
		storage: {
			type:        *"jbod" | "ephemeral"
			deleteClaim: bool | *false
		}
	}

	$resources: {
		"\($metadata.id)-cluster": resources.#KafkaCluster & {
			#KubernetesResource
			metadata: {
				name:      $metadata.id
				namespace: k8s.namespace
			}
			spec: {
				"kafka": {
					replicas: kafka.replicas.count
					version:  kafka.version
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
						"inter.broker.protocol.version":            kafka.version
					}
					storage: {
						type: config.storage.type
						if config.storage.type == "jbod" {
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
				}
				zookeeper: {
					replicas: 3
					if config.storage.type == "jbod" {
						storage: {
							type:        "persistent-claim"
							size:        "5Gi"
							deleteClaim: true
						}
					}
					if config.storage.type == "ephemeral" {
						storage: {
							type: "ephemeral"
						}
					}

				}
				entityOperator: {
					userOperator: {}
				}
			}

		}
	}
}
