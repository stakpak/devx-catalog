package components

import "guku.io/devx/v1/traits"

#DynamoDB: this={
	traits.#Workload
	traits.#Exposable

	dynamodb: persistent: bool | *true

	restart: "always"
	containers: default: {
		image: "amazon/dynamodb-local:latest"
		if !dynamodb.persistent {
			command: ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-inMemory"]
		}

		if dynamodb.persistent && this.volumes != _|_ {
			command: ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-dbPath", "/home/dynamodblocal/data"]
			mounts: [{
				volume:   this.volumes.default
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
