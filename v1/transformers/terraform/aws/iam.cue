package aws

import (
	"encoding/json"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	resources "stakpak.dev/devx/v1/resources/aws"
	schema "stakpak.dev/devx/v1/transformers/terraform"
)

#AddIAMUser: v1.#Transformer & {
	traits.#User
	users: [string]: {
		username: string
		...
	}
	for _, user in users {
		$resources: terraform: schema.#Terraform & {
			resource: {
				aws_iam_user: "\(user.username)": name:         user.username
				aws_iam_access_key: "\(user.username)": "user": "${aws_iam_user.\(user.username).name}"
			}
		}
	}
}

#AddIAMPermissions: v1.#Transformer & {
	traits.#User
	$metadata: _

	users: [string]: _
	policies: [string]: {
		actions: [...string]
		resources: [...string]
		condition: [string]: _
	}
	$resources: terraform: schema.#Terraform & {
		resource: {
			for _, user in users {
				for name, policy in policies {
					aws_iam_policy: "\(user.username)_\(name)": {
						"name":   "\(user.username)-\(name)"
						"policy": json.Marshal(resources.#IAMPolicy &
							{
								Version: "2012-10-17"
								Statement: [
									{
										Sid:       "IAMUserPolicy"
										Effect:    "Allow"
										Action:    policy.actions
										Resource:  policy.resources
										Condition: policy.condition
									},
								]
							})
					}
					aws_iam_user_policy_attachment: "\(user.username)_\(name)": {
						"user":     "${aws_iam_user.\(user.username).name}"
						policy_arn: "${aws_iam_policy.\(user.username)_\(name).arn}"
					}
				}
			}
		}
	}
}
