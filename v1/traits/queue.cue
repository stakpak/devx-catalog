package traits

import (
	"guku.io/devx/v1"
)

// a RabbitMQ instance
#RabbitMQ: v1.#Trait & {
	$metadata: traits: RabbitMQ: null
	rabbitmq: {
		name:    string
		version: "3.9.29" | "3.10.24" | *"3.11.18" | "3.12.0"

		port: 5672

		host: string

		replicas: uint | *1

		persistent: bool | *false
	}
}
