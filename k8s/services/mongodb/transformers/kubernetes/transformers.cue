package kubernetes

import (
	"strings"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/mongodb/resources"
	corev1 "k8s.io/api/core/v1"
	rbacv1 "k8s.io/api/rbac/v1"
)

#KubernetesResource: {
	$metadata: labels: {
		driver: "kubernetes"
		type:   "\(apiVersion)/\(strings.ToLower(kind))"
	}
	apiVersion: string
	kind:       string
}

#AddDatabase: v1.#Transformer & {
	traits.#Database
	$metadata: _
	$dependencies: [...string]

	mongodb: {
		members: (uint & >1) | *3
		...
	}
	k8s: {
		namespace: string
		...
	}
	database: {
		host:     "\($metadata.id)-svc.\(k8s.namespace).svc.cluster.local"
		engine:   "mongodb"
		username: string
		password: v1.#Secret
		...
	}

	$resources: {
		"\($metadata.id)-mongodb-sa": {
			#KubernetesResource
			corev1.#ServiceAccount
			apiVersion: "v1"
			kind:       "ServiceAccount"
			metadata: {
				name:      "mongodb-database"
				namespace: k8s.namespace
			}
		}

		"\($metadata.id)-mongodb-role": {
			#KubernetesResource
			rbacv1.#Role
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "Role"
			metadata: {
				name:      "mongodb-database"
				namespace: k8s.namespace
			}
			rules: [
				{
					apiGroups: [""]
					resources: ["secrets"]
					verbs: ["get"]
				},
				{
					apiGroups: [""]
					resources: ["pods"]
					verbs: ["patch", "delete", "get"]
				},
			]
		}

		"\($metadata.id)-mongodb-role-binding": {
			#KubernetesResource
			rbacv1.#RoleBinding
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "RoleBinding"
			metadata: {
				name:      "mongodb-database"
				namespace: k8s.namespace
			}
			subjects: [{
				kind: "ServiceAccount"
				name: "mongodb-database"
			}]
			roleRef: {
				kind:     "Role"
				name:     "mongodb-database"
				apiGroup: "rbac.authorization.k8s.io"
			}
		}

		"\($metadata.id)-mongodb": resources.#MongoDBCommunity & {
			#KubernetesResource
			metadata: {
				name:      $metadata.id
				namespace: k8s.namespace
			}
			spec: {
				if mongodb.members > 1 {
					type: "ShardedCluster" | *"ReplicaSet"
				}
				if mongodb.members == 1 {
					type: "Standalone"
				}
				members:  mongodb.members
				arbiters: 1
				version:  database.version
				security: {
					tls: {
						enabled:  false
						optional: true
					}
					authentication: modes: [...string] | *["SCRAM"]
				}
				users: [
					{
						name: database.username
						passwordSecretRef: {
							name: database.password.name
							key:  database.password.key
						}
						roles: []
						scramCredentialsSecretName: "\(database.password.name)-scram"
						connectionStringSecretName: "\(database.password.name)-connection"
					},
					...,
				]
			}
		}
	}
}
