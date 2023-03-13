package aws

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddVPC: v1.#Transformer & {
	traits.#VPC
	vpc: _
	$resources: terraform: schema.#Terraform & {
		data: aws_availability_zones: azs: {
			state: "available"
		}
		module: "vpc_\(vpc.name)": {
			source:  "terraform-aws-modules/vpc/aws"
			version: string | *"3.12.0"

			name: vpc.name
			cidr: vpc.cidr

			azs: [
				for i, _ in vpc.subnets.private {
					"${data.aws_availability_zones.azs.names[\(i)]}"
				},
			]
			private_subnets: vpc.subnets.private
			public_subnets:  vpc.subnets.public

			enable_nat_gateway: bool | *true
			single_nat_gateway: bool | *true
			enable_vpn_gateway: bool | *false

			enable_dns_support:   bool | *true
			enable_dns_hostnames: bool | *true

			tags: {
				terraform: "true"
			}
		}
		output: "vpc_\(vpc.name)_vpc_id": value:             "${module.vpc_\(vpc.name).vpc_id}"
		output: "vpc_\(vpc.name)_public_subnet_ids": value:  "${module.vpc_\(vpc.name).public_subnets}"
		output: "vpc_\(vpc.name)_private_subnet_ids": value: "${module.vpc_\(vpc.name).private_subnets}"
	}
}
