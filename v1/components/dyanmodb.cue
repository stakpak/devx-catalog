package components

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

#DynamoDB: v1.#Trait & {
	traits.#Workload
	traits.#Exposable

	dynamodb: persistent: bool | *true

	restart: "always"
	containers: default: {
		image: "amazon/dynamodb-local:latest"
		if !dynamodb.persistent {
			command: ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-inMemory"]
		}

		if dynamodb.persistent {
			command: ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-dbPath", "/home/dynamodblocal/data"]
			mounts: [{
				volume:   volumes.default
				path:     "/home/dynamodblocal/data"
				readOnly: false
			}]
		}
	}
	if dynamodb.persistent {
		traits.#Volume
		volumes: default: persistent: "dynamodb-data"
	}
	endpoints: default: ports: [
		{
			port: 8000
		},
	]
}
