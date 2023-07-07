package resources

import (
	"stakpak.dev/devx/k8s"
	"github.com/mongodb/mongodb-kubernetes-operator/api/v1"
)

#MongoDBCommunity: {
	k8s.#KubernetesResource
	v1.#MongoDBCommunity
	apiVersion: "mongodbcommunity.mongodb.com/v1"
	kind:       "MongoDBCommunity"
	metadata: namespace!: string
}
#MongoDBUser: {
	k8s.#KubernetesResource
	v1.#MongoDBUser
	apiVersion: "mongodbcommunity.mongodb.com/v1"
	kind:       "MongoDBUser"
	metadata: namespace!: string
}
