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
			resource: aws_lb_listener: "gateway_\(gateway.name)_\(name)": {
				load_balancer_arn: "${resource.aws_lb.gateway_\(gateway.name).arn}"
				port:              listener.port
				protocol:          listener.protocol

				default_action: {
					type: "fixed-response"
					fixed_response: {
						content_type: "text/plain"
						message_body: "Not Found"
						status_code:  "404"
					}
				}

				tags: {
					terraform: "true"
				}
			}
		}

		output: "gateway_\(gateway.name)_load_balancer_host": value: "${aws_lb.gateway_\(gateway.name).dns_name}"
		output: "gateway_\(gateway.name)_security_group": value:     "${aws_security_group.gateway_\(gateway.name).name}"
	}
}

#AddHTTPRoute: v1.#Transformer & {
	traits.#HTTPRoute
	aws: {
		vpc: {
			name: string
			...
		}
		...
	}
	http: _
	$resources: terraform: schema.#Terraform & {
		data: {
			aws_vpc: "\(aws.vpc.name)": tags: Name: aws.vpc.name
			aws_lb: "gateway_\(http.gateway.gateway.name)": name:             http.gateway.gateway.name
			aws_security_group: "gateway_\(http.gateway.gateway.name)": name: "gateway-\(http.gateway.gateway.name)"
			aws_lb_listener: "gateway_\(http.gateway.gateway.name)_\(http.listener)": {
				load_balancer_arn: "${data.aws_lb.gateway_\(http.gateway.gateway.name).arn}"
				port:              http.gateway.gateway.listeners[http.listener].port
			}
		}
		resource: {
			for ruleName, rule in http.rules {
				for _, backend in rule.backends {
					aws_security_group: "gateway_\(http.gateway.gateway.name)_\(backend.component.$metadata.id)_\(backend.port)": {
						name:   "gateway-\(http.gateway.gateway.name)-\(backend.component.$metadata.id)-\(backend.port)"
						vpc_id: "${data.aws_vpc.\(aws.vpc.name).id}"
						ingress: [{
							protocol:  "tcp"
							from_port: backend.port
							to_port:   backend.port
							security_groups: [
								"${data.aws_security_group.gateway_\(http.gateway.gateway.name).id}",
							]
							description:      null
							ipv6_cidr_blocks: null
							cidr_blocks:      null
							prefix_list_ids:  null
							self:             null
						}]
						egress: [{
							protocol:  "-1"
							from_port: 0
							to_port:   0
							cidr_blocks: ["0.0.0.0/0"]
							security_groups:  null
							description:      null
							ipv6_cidr_blocks: null
							prefix_list_ids:  null
							self:             null
						}]
					}
					aws_lb_target_group: "\(http.gateway.gateway.name)_\(http.listener)_\(backend.component.$metadata.id)_\(backend.port)": {
						"name":      "\(http.gateway.gateway.name)-\(http.listener)-\(backend.component.$metadata.id)-\(backend.port)"
						port:        http.gateway.gateway.listeners[http.listener].port
						protocol:    http.gateway.gateway.listeners[http.listener].protocol
						vpc_id:      "${data.aws_vpc.\(aws.vpc.name).id}"
						target_type: "ip"
					}
				}
				aws_lb_listener_rule: "\(http.gateway.gateway.name)_\(ruleName)": {
					listener_arn: "${data.aws_lb_listener.gateway_\(http.gateway.gateway.name)_\(http.listener).arn}"
					priority:     uint | *100
					condition: [
						{
							path_pattern: values: [rule.match.path]
						},
						if len(http.hostnames) > 0 {
							{
								host_header: values: http.hostnames
							}
						},
						if rule.match.method != _|_ {
							{
								http_request_method: values: [rule.match.method]
							}
						},
						for header, value in rule.match.headers {
							{
								http_header: {
									http_header_name: header
									values: [value]
								}
							}
						},
					]

					action: {
						type: "forward"
						if len(rule.backends) == 1 {
							target_group_arn: "${aws_lb_target_group.\(http.gateway.gateway.name)_\(http.listener)_\(rule.backends[0].component.$metadata.id)_\(rule.backends[0].port).arn}"
						}
						if len(rule.backends) > 1 {
							forward: {
								target_group: [
									for _, backend in rule.backends {
										{
											arn: "${aws_lb_target_group.\(http.gateway.gateway.name)_\(http.listener)_\(backend.component.$metadata.id)_\(backend.port).arn}"
											if backend.weight != _|_ {
												weight: backend.weight
											}
										}
									},
								]
							}
						}
					}
				}
			}
		}
	}
}
