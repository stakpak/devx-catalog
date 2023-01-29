package main

import (
	"encoding/json"
	"guku.io/devx/v1"
	resources "guku.io/devx/v1/resources/aws"
	"guku.io/devx/v1/transformers/terraform/aws"
	schema "guku.io/devx/v1/transformers/terraform"
)

_addMSKUsers: v1.#TestCase & {
	$metadata: test: "add msk user"
	transformer: aws.#AddMSKUser

	input: {
		$metadata: id: "main"
		kafka: {
			name: "main"
		}
		secrets: userCred: name: "usera"
	}
	output: {
		$resources: terraform: schema.#Terraform & {
			data: aws_kms_alias: "msk_scram_main": name:     "alias/msk-scram-main"
			data: aws_msk_cluster: "msk_main": cluster_name: "main"
			resource: aws_msk_scram_secret_association: "msk_user_usera": {
				cluster_arn: "${data.aws_msk_cluster.msk_main.arn}"
				secret_arn_list: ["${aws_secretsmanager_secret.msk_user_usera.arn}"]

				depends_on: ["aws_secretsmanager_secret.msk_user_usera"]
			}
			resource: aws_secretsmanager_secret: "msk_user_usera": {
				name:       "AmazonMSK_usera"
				kms_key_id: "${data.aws_kms_alias.msk_scram_main.target_key_id}"
			}
			resource: random_password: "secret_msk_user_usera": {
				length:  32
				special: false
			}
			resource: aws_secretsmanager_secret_version: "msk_user_usera": {
				secret_id:     "${aws_secretsmanager_secret.msk_user_usera.id}"
				secret_string: json.Marshal({
					username: "usera"
					password: "${random_password.secret_msk_user_usera.result}"
				})
			}
			resource: aws_secretsmanager_secret_policy: "msk_user_usera": {
				secret_arn: "${aws_secretsmanager_secret.msk_user_usera.arn}"
				policy:     json.Marshal(resources.IAMPolicy & {
					Version: "2012-10-17"
					Statement: [ {
						Sid:    "AWSKafkaResourcePolicy"
						Effect: "Allow"
						Principal: Service: "kafka.amazonaws.com"
						Action:   "secretsmanager:getSecretValue"
						Resource: "${aws_secretsmanager_secret.msk_user_usera.arn}"
					}]
				})
			}
		}
	}

	expect: {}
}
