package aws

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

// set secret key to secret manager arn
#AddSecretManagerKey: v1.#Transformer & {
	traits.#Secret
	aws: {
		region:  string
		account: string
		...
	}
	secrets: [string]: {
		name:     _
		property: string | *""
		version:  string | *""
		key:      "arn:aws:secretsmanager:\(aws.region):\(aws.account):secret:\(name):\(property)::\(version)"
	}
}
