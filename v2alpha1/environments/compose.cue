package environments

import (
	"guku.io/devx/v1"
	"guku.io/devx/v2alpha1"
	"guku.io/devx/v1/transformers/compose"
)

#Compose: v2alpha1.#StackBuilder & {
	drivers: compose: output: dir: ["."]
	flows: {
		"compose/add-service": pipeline: [compose.#AddComposeService]
		"compose/expose-service": pipeline: [compose.#ExposeComposeService]
		"compose/add-database": pipeline: [compose.#AddDatabase]
		"compose/add-redis": pipeline: [compose.#AddRedis]
		"compose/add-rabbitmq": pipeline: [compose.#AddRabbitMQ]
		"compose/add-volume": pipeline: [compose.#AddComposeVolume]
		"compose/add-kafka": pipeline: [compose.#AddKafka]
		"compose/add-kafka-user": pipeline: [
			compose.#AddKafka,
			compose.#AddKafkaUser,
		]

		"ignore-secret": {
			match: traits: Secret: null
			pipeline: []
		}
		"ignore-replicable": {
			match: traits: Replicable: null
			pipeline: []
		}
		"ignore-http-route": {
			match: traits: HTTPRoute: null
			pipeline: [v1.#Transformer & {
				http: gateway: {
					name:   "<none>"
					public: false
					listeners: [string]: {
						hostname: "<none>"
						port:     80
						protocol: "HTTP"
					}
				}
			}]
		}
	}
}
