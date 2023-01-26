package compose

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

// add a compose service for a database
#AddDatabase: v1.#Transformer & {
	traits.#Database
	$metadata: _
	$dependencies: [...string]

	database: host:      "\($metadata.id)"
	$resources: compose: #Compose & {
		services: "\($metadata.id)": {
			if database.engine == "postgres" {
				image: "postgres:\(database.version)-alpine"
			}
			ports: [
				"\(database.port)",
			]
			if database.persistent {
				if database.engine == "postgres" {
					volumes: ["\($metadata.id)-data:/var/lib/postgresql/data"]
				}
			}

			_username: string
			_password: string
			if (database.username & string) != _|_ {
				_username: database.username
			}
			if (database.username & v1.#Secret) != _|_ {
				_username: database.username.name
			}
			if (database.password & string) != _|_ {
				_password: database.password
			}
			if (database.password & v1.#Secret) != _|_ {
				_password: "\(database.password.name)-password"
			}

			if database.engine == "postgres" {
				environment: {
					POSTGRES_USER:     _username
					POSTGRES_PASSWORD: _password
					POSTGRES_DB:       database.database
				}
			}

			depends_on: [
				for id in $dependencies if services[id] != _|_ {id},
			]
			restart: "no"
		}
		if database.persistent {
			volumes: "\($metadata.id)-data": null
		}
	}
}

// add a compose service for kafka
#AddKafka: v1.#Transformer & {
	traits.#Kafka
	$metadata: _
	$dependencies: [...string]

	kafka: {
		name: string | *$metadata.id
		brokers: count: 1
		bootstrapServers: "\($metadata.id):9092"
	}

	$resources: compose: #Compose & {
		volumes: "\($metadata.id)-config": null

		services: {
			"\($metadata.id)-zookeeper": {
				image: "confluentinc/cp-zookeeper:3.3.1"
				depends_on: [
					"\($metadata.id)-config",
					for id in $dependencies if services[id] != _|_ {id},
				]
				ports: [
					"2181:2181",
				]
				environment: {
					ZOOKEEPER_CLIENT_PORT: "2181"
					ZOOKEEPER_TICK_TIME:   "2000"
					KAFKA_OPTS:            "-Djava.security.auth.login.config=/etc/config/zookeeper.jaas.conf -Dzookeeper.authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider -Dzookeeper.allowSaslFailedClients=false -Dzookeeper.requireClientAuthScheme=sasl"
				}
				volumes: [
					"\($metadata.id)-config:/etc/config",
				]
			}

			"\($metadata.id)": {
				image: "confluentinc/cp-kafka:3.3.1"
				depends_on: [
					"\($metadata.id)-config",
					for id in $dependencies if services[id] != _|_ {id},
				]
				ports: [
					"9092:9092",
					"29092:29092",
				]
				environment: {
					KAFKA_BROKER_ID:                            "1"
					KAFKA_ZOOKEEPER_CONNECT:                    "\($metadata.id)-zookeeper:2181"
					KAFKA_LISTENERS:                            "SASL_PLAINTEXT://:9092"
					KAFKA_LISTENER_SECURITY_PROTOCOL_MAP:       "SASL_PLAINTEXT:SASL_PLAINTEXT"
					KAFKA_ADVERTISED_LISTENERS:                 "SASL_PLAINTEXT://\($metadata.id):9092"
					KAFKA_SASL_ENABLED_MECHANISMS:              "SCRAM-SHA-256"
					KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL: "SCRAM-SHA-256"
					KAFKA_INTER_BROKER_LISTENER_NAME:           "SASL_PLAINTEXT"
					KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR:     "1"
					KAFKA_OPTS:                                 "-Djava.security.auth.login.config=/etc/config/kafka.jaas.conf"
				}
				volumes: [
					"\($metadata.id)-config:/etc/config",
				]
			}

			"\($metadata.id)-add-users": {
				image: "confluentinc/cp-kafka:3.3.1"
				depends_on: [
					"\($metadata.id)-zookeeper",
					"\($metadata.id)-config",
					for id in $dependencies if services[id] != _|_ {id},
				]
				command: [
					"/bin/bash",
					"-c",
					"""
                    set -x
                    cub zk-ready \($metadata.id)-zookeeper:2181 120
					kafka-configs --zookeeper \($metadata.id)-zookeeper:2181 --alter --add-config 'SCRAM-SHA-256=[iterations=4096,password=broker]' --entity-type users --entity-name broker
					""",
					...string,
				]
				environment: {
					KAFKA_BROKER_ID:         "ignored"
					KAFKA_ZOOKEEPER_CONNECT: "ignored"
					KAFKA_OPTS:              "-Djava.security.auth.login.config=/etc/kafka/kafka.jaas.conf"
				}
				volumes: [
					"\($metadata.id)-config:/etc/kafka",
				]
			}

			"\($metadata.id)-config": {
				image: "alpine:3.14"
				depends_on: [
					for id in $dependencies if services[id] != _|_ {id},
				]
				command: [
					"/bin/sh",
					"-c",
					"""
						cat > /etc/config/kafka.jaas.conf <<EOL
						KafkaServer {
						    org.apache.kafka.common.security.scram.ScramLoginModule required
						    username=\"broker\"
						    password=\"broker\";
						};
						Client {
						    org.apache.zookeeper.server.auth.DigestLoginModule required
						    username=\"kafka\"
						    password=\"kafka\";
						};
						EOL
						cat > /etc/config/zookeeper.jaas.conf <<EOL
						Server {
						    org.apache.zookeeper.server.auth.DigestLoginModule required
						    user_kafka=\"kafka\";
						};
						EOL
						""",
				]
				volumes: ["\($metadata.id)-config:/etc/config"]
			}
		}
	}
}

#AddKafkaUser: v1.#Transformer & {
	traits.#Kafka
	traits.#Secret
	kafka:     _
	secrets:   _
	$metadata: _
	$resources: compose: #Compose & {
		services: "\($metadata.id)-add-users": command: [
			string,
			string,
			string,
			for _, secret in secrets {
				"&& kafka-configs --zookeeper \($metadata.id)-zookeeper:2181 --alter --add-config 'SCRAM-SHA-256=[iterations=4096,password=\(secret.name)]' --entity-type users --entity-name \(secret.name)"
			},
		]
	}
}
