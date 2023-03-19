package aws

import (
	"net"
	"list"
	"strings"
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddGateway: v1.#Transformer & {
	traits.#Gateway
	gateway: _
	aws: {
		vpc: traits.#VPC
		...
	}
	createDNS:        bool | *true
	createTLS:        bool | *true
	apexDomainLength: uint | *2
	$resources: terraform: schema.#Terraform & {
		resource: aws_lb: "gateway_\(gateway.name)": {
			name:     gateway.name
			internal: !gateway.public

			_protocols: [
				for _, listener in gateway.listeners {
					listener.protocol
				},
			]
			if list.Contains(_protocols, "HTTP") || list.Contains(_protocols, "HTTPS") {
				load_balancer_type: "application"
			}
			if list.Contains(_protocols, "TCP") || list.Contains(_protocols, "TLS") {
				load_balancer_type: "network"
			}

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

		let _groupedListeners = {
			for _, listener in gateway.listeners {
				"\(listener.port)": {
					hostnames: "\(listener.hostname)": null
					protocol: listener.protocol
					port:     listener.port
					if protocol == "TLS" || protocol == "HTTPS" {
						tls: listener.tls
					}
				}
			}
		}

		let _hostnames = list.SortStrings([ for address in gateway.addresses if net.FQDN(address) {address}])
		for index, hostname in _hostnames {
			let _hostnameParts = strings.Split(hostname, ".")
			let _apexDomain = strings.Join(list.Drop(_hostnameParts, len(_hostnameParts)-apexDomainLength), ".") & net.FQDN
			let _apexDomainName = strings.Replace(_apexDomain, ".", "_", -1)
			if createDNS {
				data: aws_route53_zone: "\(_apexDomainName)": {
					name:         _apexDomain
					private_zone: !gateway.public
				}
				resource: aws_route53_record: "\(gateway.name)_\(index)": {
					zone_id: "${data.aws_route53_zone.\(_apexDomainName).zone_id}"
					name:    hostname
					type:    "A"
					alias: {
						name:                   "${aws_lb.gateway_\(gateway.name).dns_name}"
						zone_id:                "${aws_lb.gateway_\(gateway.name).zone_id}"
						evaluate_target_health: true
					}
				}

				if createTLS {
					resource: aws_acm_certificate: "\(gateway.name)_\(index)": {
						domain_name:       hostname
						validation_method: "DNS"
						lifecycle: create_before_destroy: true
					}
					resource: aws_route53_record: "zone_\(index)": {
						for_each:        "${{for dvo in aws_acm_certificate.\(gateway.name)_\(index).domain_validation_options : dvo.domain_name => {name=dvo.resource_record_name, record=dvo.resource_record_value, type=dvo.resource_record_type}}}"
						allow_overwrite: true
						name:            "${each.value.name}"
						records: [
							"${each.value.record}",
						]
						ttl:     60
						type:    "${each.value.type}"
						zone_id: "${data.aws_route53_zone.\(_apexDomainName).zone_id}"
					}
					resource: aws_acm_certificate_validation: "\(gateway.name)_\(index)": {
						certificate_arn:         "${aws_acm_certificate.\(gateway.name)_\(index).arn}"
						validation_record_fqdns: "${[for record in aws_route53_record.zone_\(index) : record.fqdn]}"
					}
				}
			}

		}

		for _, listener in _groupedListeners {
			if listener.protocol == "TLS" || listener.protocol == "HTTPS" {
				for index, _ in _hostnames if index > 0 {
					resource: aws_lb_listener_certificate: "\(gateway.name)_\(index)": {
						certificate_arn: "${aws_acm_certificate_validation.\(gateway.name)_\(index).certificate_arn}"
						listener_arn:    "${aws_lb_listener.gateway_\(gateway.name)_\(listener.port).arn}"
					}
				}
			}

			resource: aws_lb_listener: "gateway_\(gateway.name)_\(listener.port)": {
				load_balancer_arn: "${resource.aws_lb.gateway_\(gateway.name).arn}"
				port:              listener.port
				protocol:          listener.protocol

				if protocol == "TLS" || protocol == "HTTPS" {
					ssl_policy:      string | *"ELBSecurityPolicy-TLS-1-1-2017-01"
					certificate_arn: "${aws_acm_certificate_validation.\(gateway.name)_0.certificate_arn}"
				}
				if protocol == "TLS" {
					alpn_policy: string | *"HTTP2Preferred"
				}

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
	$metadata: _
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
			aws_lb: "gateway_\(http.gateway.name)": name:             http.gateway.name
			aws_security_group: "gateway_\(http.gateway.name)": name: "gateway-\(http.gateway.name)"
			aws_lb_listener: "gateway_\(http.gateway.name)_\(http.gateway.listeners[http.listener].port)": {
				load_balancer_arn: "${data.aws_lb.gateway_\(http.gateway.name).arn}"
				port:              http.gateway.listeners[http.listener].port
			}
		}
		resource: {
			for ruleName, rule in http.rules {
				for _, backend in rule.backends {
					aws_security_group: "gateway_\(http.gateway.name)_\(backend.name)_\(backend.port)": {
						name:   "gateway-\(http.gateway.name)-\(backend.name)-\(backend.port)"
						vpc_id: "${data.aws_vpc.\(aws.vpc.name).id}"
						ingress: [{
							protocol:  "tcp"
							from_port: backend.port
							to_port:   backend.port
							security_groups: [
								"${data.aws_security_group.gateway_\(http.gateway.name).id}",
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
					aws_lb_target_group: "\(http.gateway.name)_\(http.listener)_\(backend.name)_\(backend.port)": {
						"name":      "\(http.gateway.name)-\(http.listener)-\(backend.name)-\(backend.port)"
						port:        http.gateway.listeners[http.listener].port
						vpc_id:      "${data.aws_vpc.\(aws.vpc.name).id}"
						target_type: "ip"

						let _port = [
							for p in backend.endpoint.ports if p.port == backend.port {
								p
							},
						][0]
						let _protocol = http.gateway.listeners[http.listener].protocol
						health_check: {
							enabled: bool | *true
							if _port.health != _|_ {
								if _port.health.path != _|_ {
									path: _port.health.path
								}
								if _port.health.protocol != _|_ {
									protocol: _port.health.protocol
								}
								if _port.health.periodSeconds != _|_ {
									interval: _port.health.periodSeconds & >=5 & <=300
								}
								if _port.health.successThreshold != _|_ {
									healthy_threshold: _port.health.successThreshold & >=2 & <=10
								}
								if _port.health.failureThreshold != _|_ {
									unhealthy_threshold: _port.health.failureThreshold & >=2 & <=10
								}
							}
						}
						if _protocol == "HTTP" {
							protocol: "HTTP"
							health_check: protocol: "HTTP"
						}
						if _protocol == "HTTPS" {
							if http.gateway.listeners[http.listener].tls.mode == "TERMINATE" {
								protocol: "HTTP"
								health_check: protocol: "HTTP"
							}
						}
					}
				}
				aws_lb_listener_rule: "\(http.gateway.name)_\(http.listener)_\($metadata.id)_\(ruleName)": {
					listener_arn: "${data.aws_lb_listener.gateway_\(http.gateway.name)_\(http.gateway.listeners[http.listener].port).arn}"
					priority?:    uint
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

					if rule.redirect != _|_ {
						action: {
							type: "redirect"
							redirect: {
								if rule.redirect.scheme != _|_ {
									if rule.redirect.scheme == "http" {
										protocol: "HTTP"
									}
									if rule.redirect.scheme == "https" {
										protocol: "HTTPS"
									}
								}
								if rule.redirect.hostname != _|_ {
									host: rule.redirect.hostname
								}
								if rule.redirect.path != _|_ {
									path: rule.redirect.path
								}
								if rule.redirect.port != _|_ {
									port: "\(rule.redirect.port)"
								}
								status_code: "HTTP_\(rule.redirect.statusCode)"
							}
						}
					}

					if rule.redirect == _|_ {
						action: {
							type: "forward"
							if len(rule.backends) == 1 {
								target_group_arn: "${aws_lb_target_group.\(http.gateway.name)_\(http.listener)_\(rule.backends[0].name)_\(rule.backends[0].port).arn}"
							}
							if len(rule.backends) > 1 {
								forward: {
									target_group: [
										for _, backend in rule.backends {
											{
												arn: "${aws_lb_target_group.\(http.gateway.name)_\(http.listener)_\(backend.name)_\(backend.port).arn}"
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
}
