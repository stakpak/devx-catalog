package traits

import (
	"guku.io/devx/v1"
)

// a RabbitMQ instance
#RabbitMQ: v1.#Trait & {
	$metadata: traits: RabbitMQ: null
	rabbitmq: {
		name:    string
		version: string | *"3.10.10"
		host:    string
	}
}
