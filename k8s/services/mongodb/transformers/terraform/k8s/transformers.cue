package k8s

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/mongodb/resources"
	schema "stakpak.dev/devx/v1/transformers/terraform"
)

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

	$resources: terraform: schema.#Terraform & {
		resource: kubernetes_service_account: "\($metadata.id)-mongodb": {
			metadata: {
				name:      "mongodb-database"
				namespace: k8s.namespace
			}
		}

		resource: kubernetes_role_v1: "\($metadata.id)-mongodb": {
			metadata: {
				name:      "mongodb-database"
				namespace: k8s.namespace
			}
			rule: [
				{
					api_groups: [""]
					resources: ["secrets"]
					verbs: ["get"]
				},
				{
					api_groups: [""]
					resources: ["pods"]
					verbs: ["patch", "delete", "get"]
				},
			]
		}

		resource: kubernetes_role_binding_v1: "\($metadata.id)-mongodb": {
			metadata: {
				name:      "mongodb-database"
				namespace: k8s.namespace
			}
			subject: [{
				kind: "ServiceAccount"
				name: "mongodb-database"
			}]
			role_ref: {
				kind:      "Role"
				name:      "mongodb-database"
				api_group: "rbac.authorization.k8s.io"
			}
		}

		resource: kubernetes_manifest: "\($metadata.id)-mongodb": {
			manifest: resources.#MongoDBCommunity & {
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
								if database.password.property != _|_ {
									key: database.password.property
								}
								if database.password.property == _|_ {
									key: "value"
								}
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
}
