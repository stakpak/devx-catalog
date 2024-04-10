package traits

import (
	"stakpak.dev/devx/v1"
)

// a Kafka instance
#Kafka: v1.#Trait & {
	$metadata: traits: Kafka: null
	kafka: {
		name:    string
		version: string | *"3.7.0"
		brokers: {
			count:  uint | *3
			sizeGB: uint | *1
		}
		controllers: {
			count:  uint | *3
			sizeGB: uint | *1
		}
		replicas: {
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
		engine:     "postgres" | "mongodb" | "mysql"
		version!:   string
		persistent: bool | *true

		if engine == "postgres" {
			port: uint | *5432
		}
		if engine == "mongodb" {
			port: uint | *27017
		}
		if engine == "mysql" {
			port: uint | *3306
		}

		database: string | *"main"

		host:     string
		username: string | v1.#Secret
		password: string | v1.#Secret

		sizeGB?: uint
	}
}
