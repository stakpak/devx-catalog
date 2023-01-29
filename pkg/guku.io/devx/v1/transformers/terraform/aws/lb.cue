package aws

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddGateway: v1.#Transformer & {
	traits.#Gateway
	gateway: _
	aws: {
		lbType: "application"
		vpc:    traits.#VPC
	}
	$resources: terraform: schema.#Terraform & {
		resource: aws_lb: "gateway_\(gateway.name)": {
			name:               gateway.name
			internal:           !gateway.public
			load_balancer_type: aws.lbType
			security_groups: [
				"${aws_security_group.gateway_\(gateway.name).id}",
			]

			if gateway.public {
				subnets: "${module.vpc_\(aws.vpc.vpc.name).public_subnets}"
			}
			if !gateway.public {
				subnets: "${module.vpc_\(aws.vpc.vpc.name).private_subnets}"
			}

			tags: {
				terraform: "true"
			}
		}
		resource: aws_security_group: "gateway_\(gateway.name)": {
			name:   "gateway-\(gateway.name)"
			vpc_id: "${module.vpc_\(aws.vpc.vpc.name).vpc_id}"

			ingress: [
				for _, listener in gateway.listeners {
					{
						protocol:  *"tcp" | "udp" | "icmp" | "icmpv6"
						from_port: listener.port
						to_port:   listener.port

						if gateway.public {
							cidr_blocks: ["0.0.0.0/0"]
						}
						if !gateway.public {
							cidr_blocks: [aws.vpc.vpc.cidr]
						}

						description:      null
						ipv6_cidr_blocks: null
						prefix_list_ids:  null
						self:             null
						security_groups:  null
					}
				},
			]

			egress: [{
				from_port: 0
				to_port:   0
				protocol:  "-1"
				cidr_blocks: ["0.0.0.0/0"]

				description:      null
				ipv6_cidr_blocks: null
				prefix_list_ids:  null
				self:             null
				security_groups:  null
			}]

			tags: {
				terraform: "true"
			}
		}

		for name, listener in gateway.listeners {
			resource: aws_lb_target_group: "gateway_\(gateway.name)_\(name)": {
				"name":      "gateway-\(gateway.name)-\(name)"
				port:        listener.port
				protocol:    listener.protocol
				vpc_id:      "${module.vpc_\(aws.vpc.vpc.name).vpc_id}"
				target_type: "ip"
				tags: {
					terraform: "true"
				}
			}
			resource: aws_lb_listener: "gateway_\(gateway.name)_\(name)": {
				load_balancer_arn: "${resource.aws_lb.gateway_\(gateway.name).arn}"
				port:              listener.port
				protocol:          listener.protocol

				default_action: {
					target_group_arn: "${resource.aws_lb_target_group.gateway_\(gateway.name)_\(name).arn}"
					type:             "forward"
				}
				tags: {
					terraform: "true"
				}
			}
			output: "gateway_\(gateway.name)_\(name)_target_goup": value: "${aws_lb_target_group.gateway_\(gateway.name)_\(name).name}"
		}

		output: "gateway_\(gateway.name)_load_balancer_host": value: "${aws_lb.gateway_\(gateway.name).dns_name}"
		output: "gateway_\(gateway.name)_security_group": value:     "${aws_security_group.gateway_\(gateway.name).name}"
	}
}
