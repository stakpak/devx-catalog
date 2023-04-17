package aws

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddRabbitMQ: v1.#Transformer & {
	traits.#RabbitMQ
	rabbitmq: _
	aws: {
		vpc: name: string
		instanceType: *"mq.t3.micro" |
			"mq.m5.large " |
			"mq.m5.xlarge" |
			"mq.m5.2xlarge" |
			"mq.m5.4xlarge"
		...
	}
	rabbitmq: host:        string | *"${aws_mq_broker.\(rabbitmq.name).instances.0.endpoints.0}"
	$resources: terraform: schema.#Terraform & {
		data: {
			aws_vpc: "\(aws.vpc.name)": tags: Name: aws.vpc.name
			aws_subnets: "\(aws.vpc.name)": {
				filter: [
					{
						name: "vpc-id"
						values: ["${data.aws_vpc.\(aws.vpc.name).id}"]
					},
					{
						name: "mapPublicIpOnLaunch"
						values: ["false"]
					},
				]
			}
			aws_subnet: "\(aws.vpc.name)": {
				count: "${length(data.aws_subnets.\(aws.vpc.name).ids)}"
				id:    "${tolist(data.aws_subnets.\(aws.vpc.name).ids)[count.index]}"
			}
		}
		resource: aws_mq_broker: "\(rabbitmq.name)": {
			broker_name: rabbitmq.name

			engine_type:        "RabbitMQ"
			engine_version:     rabbitmq.version
			storage_type:       "ebs"
			host_instance_type: aws.instanceType
			security_groups: [
				"${aws_security_group.mq_\(rabbitmq.name).id}",
			]

			apply_immediately:       true
			authentication_strategy: "simple"

			encryption_options: use_aws_owned_key: true

			user: [...{
				username: string
				password: string
			}]
		}
		resource: aws_security_group: "mq_\(rabbitmq.name)": {
			name:   "mq-\(rabbitmq.name)"
			vpc_id: "${data.aws_vpc.\(aws.vpc.name).id}"

			ingress: [
				{
					protocol:  "tcp"
					from_port: 5671
					to_port:   5671

					cidr_blocks: "${data.aws_subnet.\(aws.vpc.name).*.cidr_block}"

					description:      null
					ipv6_cidr_blocks: null
					prefix_list_ids:  null
					self:             null
					security_groups:  null
				},
			]
		}
		output: "mq_\(rabbitmq.name)_endpoint": value: "${aws_mq_broker.\(rabbitmq.name).instances.0.endpoints.0}"
	}
}

#AddRabbitMQUser: v1.#Transformer & {
	traits.#User
	aws: {
		region:  string
		account: string
		...
	}
	rabbitmq: {
		name: string
		...
	}
	users: [string]: {
		username: string
		password: {
			name: "mq-\(rabbitmq.name)-\(username)-password"
			key:  "arn:aws:ssm:\(aws.region):\(aws.account):parameter/\(name)"
		}
	}

	$resources: terraform: schema.#Terraform & {
		resource: aws_mq_broker: "\(rabbitmq.name)": {
			...
			user: [
				for _, user in users {
					{
						username: user.username
						password: "${random_password.secret_\(user.password.name).result}"
					}
				},
			]
		}

		for _, user in users {
			resource: aws_ssm_parameter: "secret_\(user.password.name)": {
				name:  user.password.name
				type:  "SecureString"
				value: "${random_password.secret_\(user.password.name).result}"
			}

			resource: random_password: "secret_\(user.password.name)": {
				length:  32
				special: false
			}
		}
	}
}
