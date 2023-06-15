package kubernetes

import (
	"strings"
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	"guku.io/devx/k8s/services/rabbitmq/resources"
)

#KubernetesResource: {
	$metadata: labels: {
		driver: "kubernetes"
		type:   "\(apiVersion)/\(strings.ToLower(kind))"
	}
	apiVersion: string
	kind:       string
}

#AddCluster: v1.#Transformer & {
	traits.#RabbitMQ
	$metadata: _
	$dependencies: [...string]

	rabbitmq: {
		host:    "\($metadata.id).\(k8s.namespace).svc.cluster.local"
		version: "3.9" | "3.10" | "3.11" | "3.12"
		port:    5672
	}

	k8s: {
		namespace: string
		...
	}

	$resources: {
		"\($metadata.id)-rabbit-mq-cluster": resources.#RabbitMQCluster & {
			#KubernetesResource
			metadata: {
				name:      $metadata.id
				namespace: k8s.namespace
			}
			spec: {
				replicas: rabbitmq.replicas
				image:    "rabbitmq:\(rabbitmq.version)"
			}
		}
	}
}
