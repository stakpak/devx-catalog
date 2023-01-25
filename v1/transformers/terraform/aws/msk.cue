package aws

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
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
