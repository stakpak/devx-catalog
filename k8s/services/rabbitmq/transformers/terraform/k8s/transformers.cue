package k8s

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/rabbitmq/resources"
	schema "stakpak.dev/devx/v1/transformers/terraform"
)

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

	$resources: terraform: schema.#Terraform & {
		resource: kubernetes_manifest: "\($metadata.id)-rabbit-mq-cluster": {
			manifest: resources.#RabbitMQCluster & {
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
}
