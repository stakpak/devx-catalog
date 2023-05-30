package traits

import (
	"guku.io/devx/v1"
)

// a redis instance
#Redis: v1.#Trait & {
	$metadata: traits: Redis: null
	redis: {
		name:    string | *$metadata.id
		version: string | *"7.0"

		port: uint | *6379

		host: string
	}
}
