package aws

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

// add a parameter store secret
#AddSSMSecretParameter: v1.#Transformer & {
	traits.#Secret
	$metadata: _
	secrets:   _
	$resources: terraform: schema.#Terraform & {
		resource: aws_ssm_parameter: {
			for _, secret in secrets {
				"secret_\(secret.name)": {
					name:  secret.key
					type:  "SecureString"
					value: "${random_password.secret_\(secret.name).result}"

					tags: {
						terraform: "true"
					}
				}
			}
		}
		resource: random_password: {
			for _, secret in secrets {
				"secret_\(secret.name)": {
					length:  32
					special: false
				}
			}
		}
	}
}

// set secret key to SSM parameter store arn
#AddSSMSecretKey: v1.#Transformer & {
	traits.#Secret
	aws: {
		region:  string
		account: string
	}
	secrets: [string]: {
		name: _
		key:  "arn:aws:ssm:\(aws.region):\(aws.account):parameter/\(name)"
	}
}
