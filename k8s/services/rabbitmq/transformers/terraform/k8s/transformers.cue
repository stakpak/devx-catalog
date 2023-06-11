package k8s

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	"guku.io/devx/k8s/services/rabbitmq/resources"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddCluster: v1.#Transformer & {
	traits.#RabbitMQ
	$metadata: _
	$dependencies: [...string]

	rabbitmq: {
		...
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
					version: rabbitmq.version
					port:    rabbitmq.port
				}
			}
		}
	}
}
