package environments

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v2alpha1"
	"stakpak.dev/devx/v1/transformers/compose"
	c "stakpak.dev/devx/v1/components"
)

#Compose: v2alpha1.#StackBuilder & {
	drivers: compose: output: dir: ["."]
	flows: {
		"compose/add-service": pipeline: [compose.#AddComposeService]
		"compose/expose-service": pipeline: [compose.#ExposeComposeService]
		"compose/add-volume": pipeline: [compose.#AddComposeVolume]
		"compose/add-database": pipeline: [compose.#AddDatabase]
		"compose/add-redis": pipeline: [compose.#AddRedis]
		"compose/add-rabbitmq": pipeline: [compose.#AddRabbitMQ]
		"compose/add-rabbitmq-user": pipeline: [compose.#AddRabbitMQUser]
		"compose/add-kafka": pipeline: [compose.#AddKafka]
		"compose/add-kafka-user": pipeline: [compose.#AddKafkaUser]

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

#ComposeWithS3: v2alpha1.#StackBuilder & #Compose & {
	components: {
		myminio: {
			c.#Minio
			minio: {
				urlScheme: "http"
				userKeys: default: {
					accessKey:    "admin"
					accessSecret: "adminadmin"
				}
				url: _
			}
		}

		[string]: s3?: {
			url:          myminio.minio.url
			accessKey:    myminio.minio.userKeys.default.accessKey
			accessSecret: myminio.minio.userKeys.default.accessSecret
		}
	}
	flows: "compose/add-s3bucket": pipeline: [compose.#AddS3Bucket]
}
