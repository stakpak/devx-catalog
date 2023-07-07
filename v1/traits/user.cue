package traits

import (
	"stakpak.dev/devx/v1"
)

// a user account
#User: v1.#Trait & {
	$metadata: traits: User: null
	users: [string]: {
		username: string
		password: string | v1.#Secret
	}
}
