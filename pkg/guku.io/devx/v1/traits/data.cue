package traits

import (
	"guku.io/devx/v1"
)

// a Kafka instance
#Kafka: v1.#Trait & {
	$metadata: traits: Kafka: null
	kafka: {
		name:    string
		version: string | *"3.3.1"
		brokers: {
			count:  uint | *3
			sizeGB: uint | *1
		}
		bootstrapServers: string
	}
}

// a database
#Database: v1.#Trait & {
	$metadata: traits: Database: null
	database: {
		name:       string | *$metadata.id
		engine:     "postgres"
		version:    string @guku(required)
		persistent: bool | *true

		if engine == "postgres" {
			port: uint | *5432
		}

		database: string | *"main"

		host:     string
		username: string | v1.#Secret
		password: string | v1.#Secret

		sizeGB?: uint
	}
}

// a postgres database (DEPRECATED)
#Postgres: v1.#Trait & {
	$metadata: traits: Postgres: null

	version:    string @guku(required)
	persistent: bool | *true
	port:       uint | *5432
	database:   string | *"default"

	host:     string
	username: string
	password: string
	url:      "postgresql://\(username):\(password)@\(host):\(port)/\(database)"
}
