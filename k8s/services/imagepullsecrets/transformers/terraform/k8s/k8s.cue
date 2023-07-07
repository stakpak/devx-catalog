package k8s

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
)

#AddIAMUserSecret: v1.#Transformer & {
	traits.#User
	$metadata: _
	users: [string]: {
		username: string
		password: name: "\(username)"
	}
	aws: {
		region:  string
		account: string
	}
	k8s: {
		namespace: string
		...
	}
	$resources: terraform: schema.#Terraform & {
		resource: kubernetes_secret_v1: {
			for _, user in users {
				"\($metadata.id)_\(user.username)": {
					metadata: {
						namespace: k8s.namespace
						name:      user.username
					}
					data: {
						accessKeyID: "${aws_iam_access_key.\(user.username).id}"
						secretKey:   "${aws_iam_access_key.\(user.username).secret}"
						region:      aws.region
						accountID:   aws.account
					}
					type: "banzaicloud.io/aws-ecr-login-config"
				}
			}
		}
	}
}
