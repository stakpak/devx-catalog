package aws

import (
	"encoding/json"
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	resources "guku.io/devx/v1/resources/aws"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddMSK: v1.#Transformer & {
	traits.#Kafka
	kafka: _
	aws: {
		vpc:                traits.#VPC
		brokerInstanceType: *"kafka.t3.small" |
			"kafka.m5.large " |
			"kafka.m5.xlarge" |
			"kafka.m5.2xlarge" |
			"kafka.m5.4xlarge" |
			"kafka.m5.8xlarge" |
			"kafka.m5.12xlarge" |
			"kafka.m5.16xlarge" |
			"kafka.m5.24xlarge"
	}
	kafka: bootstrapServers: "<unknown>"
	$resources: terraform:   schema.#Terraform & {
		resource: aws_kms_key: "msk_\(kafka.name)": {
			description:             "msk_\(kafka.name) encryption key"
			deletion_window_in_days: 7
			tags: {
				terraform: "true"
			}
		}
		resource: aws_kms_key: "msk_scram_\(kafka.name)": description: "Key for MSK Cluster Scram Secret Association"
		resource: aws_kms_alias: "msk_scram_\(kafka.name)": {
			name:          "alias/msk-scram-\(kafka.name)"
			target_key_id: "${aws_kms_key.msk_scram_\(kafka.name).key_id}"
		}
		resource: aws_msk_cluster: "msk_\(kafka.name)": {
			cluster_name:  kafka.name
			kafka_version: kafka.version

			encryption_info: encryption_at_rest_kms_key_arn: "${aws_kms_key.msk_\(kafka.name).arn}"
			client_authentication: sasl: scram: true

			number_of_broker_nodes: kafka.brokers.count
			_validateBrokerCount:   mod(kafka.brokers.count, len(aws.vpc.vpc.subnets.private)) & 0

			broker_node_group_info: {
				instance_type:  aws.brokerInstanceType
				client_subnets: "${module.vpc_\(aws.vpc.vpc.name).private_subnets}"
				security_groups: ["${aws_security_group.msk_\(kafka.name).id}"]

				storage_info: ebs_storage_info: volume_size: kafka.brokers.sizeGB
			}
			tags: {
				terraform: "true"
			}
		}
		resource: aws_security_group: "msk_\(kafka.name)": {
			name:   "msk-\(kafka.name)"
			vpc_id: "${module.vpc_\(aws.vpc.vpc.name).vpc_id}"

			ingress: [
				{
					protocol:  "tcp"
					from_port: 9096
					to_port:   9096

					cidr_blocks: [aws.vpc.vpc.cidr]

					description:      null
					ipv6_cidr_blocks: null
					prefix_list_ids:  null
					self:             null
					security_groups:  null
				},
			]
			tags: {
				terraform: "true"
			}
		}
		output: "msk_\(kafka.name)_bootstrap_brokers": value: "${aws_msk_cluster.msk_\(kafka.name).bootstrap_brokers_sasl_scram}"
	}
}

#AddMSKUser: v1.#Transformer & {
	traits.#User
	aws: {
		region:  string
		account: string
		...
	}
	kafka: {
		name: string
		...
	}
	user: _
	if (user.password & v1.#Secret) != _|_ {
		user: password: {
			name:     "AmazonMSK_\\(user.username)"
			property: "password"
			key:      "arn:aws:secretsmanager:\(aws.region):\(aws.account):secret:\(name):\(property)::"
		}
	}
	$resources: terraform: schema.#Terraform & {
		data: aws_kms_alias: "msk_scram_\(kafka.name)": name:     "alias/msk-scram-\(kafka.name)"
		data: aws_msk_cluster: "msk_\(kafka.name)": cluster_name: kafka.name
		resource: aws_msk_scram_secret_association: "msk_user_\(user.username)": {
			cluster_arn: "${data.aws_msk_cluster.msk_\(kafka.name).arn}"
			secret_arn_list: ["${aws_secretsmanager_secret.msk_user_\(user.username).arn}"]

			depends_on: ["aws_secretsmanager_secret.msk_user_\(user.username)"]
		}
		resource: aws_secretsmanager_secret: "msk_user_\(user.username)": {
			name:       "AmazonMSK_\\(user.username)"
			kms_key_id: "${data.aws_kms_alias.msk_scram_\(kafka.name).target_key_id}"
		}
		resource: random_password: "secret_msk_user_\(user.username)": {
			length:  32
			special: false
		}
		resource: aws_secretsmanager_secret_version: "msk_user_\(user.username)": {
			secret_id:     "${aws_secretsmanager_secret.msk_user_\(user.username).id}"
			secret_string: json.Marshal({
				username: user.username
				password: "${random_password.secret_msk_user_\(user.username).result}"
			})
		}
		resource: aws_secretsmanager_secret_policy: "msk_user_\(user.username)": {
			secret_arn: "${aws_secretsmanager_secret.msk_user_\(user.username).arn}"
			policy:     json.Marshal(resources.#IAMPolicy & {
				Version: "2012-10-17"
				Statement: [ {
					Sid:    "AWSKafkaResourcePolicy"
					Effect: "Allow"
					Principal: Service: "kafka.amazonaws.com"
					Action:   "secretsmanager:getSecretValue"
					Resource: secret_arn
				}]
			})
		}
	}
}
