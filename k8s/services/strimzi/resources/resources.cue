package resources

import (
	"stakpak.dev/devx/k8s"
)

#KafkaNodePool: {
	k8s.#KubernetesResource
	apiVersion: "kafka.strimzi.io/v1beta2"
	kind:       "KafkaNodePool"
	metadata: {
		name:      string
		namespace: string
		labels: {
			"strimzi.io/cluster": string
		}
	}
	spec: {
		replicas: int
		roles: [...string]
		storage: {
			type: "jbod" | "ephemeral"
			volumes: [...{
				id:          int
				type:        string
				size:        string
				deleteClaim: bool
			}]
		}
	}
}

#KafkaCluster: {
	k8s.#KubernetesResource
	apiVersion: "kafka.strimzi.io/v1beta2"
	kind:       "Kafka"
	metadata: {
		name:      string
		namespace: string
		annotations: k8s.#Annotations | *{
			"strimzi.io/node-pools": "enabled"
			"strimzi.io/kraft":      "enabled"
		}
	}
	spec: {
		kafka: {
			version:         string
			replicas:        int
			listeners: [...{
				name: string
				port: int
				type: "internal" | "route" | "nodeport"
				tls:  bool
			}]
			config: {
				"offsets.topic.replication.factor":         uint
				"transaction.state.log.replication.factor": uint
				"transaction.state.log.min.isr":            uint
				"default.replication.factor":               uint
				"min.insync.replicas":                      uint
				"inter.broker.protocol.version":            string
			}
			storage: {
				type: "jbod" | "ephemeral"
				volumes: [...{
					id:          int
					type:        string
					size:        string
					deleteClaim: bool
				}]
			}
			//   # The ZooKeeper section is required by the Kafka CRD schema while the UseKRaft feature gate is in alpha phase.
			//   # But it will be ignored when running in KRaft mode
		}
		zookeeper: {
			replicas: int
			storage: {
				type:        string
				size:        string
				deleteClaim: bool
			}

		}
		entityOperator: {
			userOperator: {...}
		}
	}
}
