package resources


import (
	"guku.io/devx/k8s"
	v1beta1 "github.com/rabbitmq/cluster-operator/api/v1beta1"
    
)

#RabbitMQCluster: {
	k8s.#KubernetesResource
	v1beta1.#RabbitmqCluster
	apiVersion: "rabbitmq.com/v1beta1"
	kind:       "RabbitmqCluster"
	metadata: namespace!: string
}