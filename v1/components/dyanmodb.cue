package components

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

#DynamoDB: v1.#Trait & {
	traits.#Workload
	traits.#Volume
	traits.#Exposable

	dynamodb: persistent: bool | *true

	restart: "always"
	containers: default: {
		image: "amazon/dynamodb-local:latest"
		command: ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-dbPath", "/home/dynamodblocal/data"]
		mounts: [{
			volume:   volumes.default
			path:     "/home/dynamodblocal/data"
			readOnly: false
		}]
	}
	volumes: default: {
		if dynamodb.persistent {
			persistent: "dynamodbdata"
		}
		if !dynamodb.persistent {
			ephemeral: "dynamodbdata"
		}
	}
	endpoints: default: ports: [
		{
			port: 8000
		},
	]
}
