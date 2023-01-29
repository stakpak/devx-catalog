package aws

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddRDS: v1.#Transformer & {
	traits.#Database
	database: _
	aws: {
		instanceClass: string | *"db.t3.micro"
		vpc:           traits.#VPC
	}
	database: host:        "<unknown>"
	$resources: terraform: schema.#Terraform & {
		module: "rds_\(database.name)": {
			source:  "terraform-aws-modules/rds/aws"
			version: "5.2.3"

			identifier: database.name

			if database.engine == "postgres" {
				engine: "postgres"
			}
			engine_version: database.version

			instance_class: aws.instanceClass

			db_name: database.database
			port:    "\(database.port)"

			if database.sizeGB != _|_ {
				allocated_storage: database.sizeGB
			}
			if database.sizeGB == _|_ {
				allocated_storage: 10
			}

			if (database.username & string) != _|_ {
				username: database.username
			}
			if (database.password & string) != _|_ {
				password: database.password
			}

			if (database.username & v1.#Secret) != _|_ {
				username: string | *"${random_password.secret_\(database.username.name).result}"
			}
			if (database.password & v1.#Secret) != _|_ {
				password: string | *"${random_password.secret_\(database.password.name).result}"
			}

			create_random_password:    false
			create_db_parameter_group: false
			create_db_subnet_group:    true

			vpc_security_group_ids: ["${aws_security_group.rds_\(database.name).id}"]
			subnet_ids: "${module.vpc_\(aws.vpc.vpc.name).private_subnets}"

			tags: {
				terraform: "true"
			}
		}
		resource: aws_security_group: "rds_\(database.name)": {
			name:   "rds-\(database.name)"
			vpc_id: "${module.vpc_\(aws.vpc.vpc.name).vpc_id}"

			ingress: [
				{
					protocol:  "tcp"
					from_port: database.port
					to_port:   database.port

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
		output: "rds\(database.name)_endpoint": value: "${module.rds_\(database.name).db_instance_endpoint}"
	}
}
