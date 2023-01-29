package aws

import (
	"list"
	"strings"
	"encoding/json"
	"strconv"
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	resources "guku.io/devx/v1/resources/aws"
	schema "guku.io/devx/v1/transformers/terraform"
)

// add an ECS service and task definition
#AddECSService: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	$metadata:  _
	containers: _

	aws: {
		region:  string
		account: string
	}
	subnets: [...string]
	clusterName: string
	launchType:  "FARGATE" | "ECS"
	appName:     string | *$metadata.id
	$resources: terraform: schema.#Terraform & {
		data: aws_ecs_cluster: "\(clusterName)": cluster_name: clusterName
		resource: {
			aws_iam_role: "task_execution_\(appName)": {
				name:               "task-execution-\(appName)"
				assume_role_policy: json.Marshal(resources.#IAMPolicy &
					{
						Version: "2012-10-17"
						Statement: [{
							Sid:    "ECSTask"
							Effect: "Allow"
							Principal: Service: "ecs-tasks.amazonaws.com"
							Action: "sts:AssumeRole"
						}]
					})
			}
			aws_iam_role_policy: "task_execution_\(appName)_default": {
				name:   "task-execution-\(appName)-default"
				role:   "${aws_iam_role.task_execution_\(appName).name}"
				policy: json.Marshal(resources.#IAMPolicy &
					{
						Version: "2012-10-17"
						Statement: [
							{
								Sid:    "ECSTaskDefault"
								Effect: "Allow"
								Action: [
									"ecr:GetAuthorizationToken",
									"ecr:BatchCheckLayerAvailability",
									"ecr:GetDownloadUrlForLayer",
									"ecr:BatchGetImage",
									"logs:CreateLogStream",
									"logs:PutLogEvents",
								]
								Resource: "*"
							},
							{
								Sid:    "ECSTaskSecret"
								Effect: "Allow"
								Action: [
									"ssm:GetParameters",
									"secretsmanager:GetSecretValue",
									"kms:Decrypt",
								]
								Resource: [
									"arn:aws:kms:\(aws.region):\(aws.account):key/*",
									for _, container in containers for _, v in container.env if (v & v1.#Secret) != _|_ {
										v.key
									},
								]
							},
						]
					})
			}
			aws_ecs_service: "\(appName)": _#ECSService & {
				name:            appName
				cluster:         "${data.aws_ecs_cluster.\(clusterName).id}"
				task_definition: "${aws_ecs_task_definition.\(appName).arn}"
				launch_type:     launchType
				network_configuration: {
					"subnets": subnets
				}
				wait_for_steady_state: true
			}
			aws_ecs_task_definition: "\(appName)": _#ECSTaskDefinition & {
				family:       appName
				network_mode: "awsvpc"
				requires_compatibilities: [launchType]

				execution_role_arn: "${aws_iam_role.task_execution_\(appName).arn}"
				task_role_arn?:     string

				_cpu: list.Sum([
					0,
					for _, container in containers if container.resources.requests.cpu != _|_ {
						strconv.Atoi(strings.TrimSuffix(container.resources.requests.cpu, "m"))
					},
				])
				_memory: list.Sum([
						0,
						for _, container in containers if container.resources.requests.memory != _|_ {
						strconv.Atoi(strings.TrimSuffix(container.resources.requests.memory, "M"))
					},
				])
				if _cpu > 0 {
					cpu: "\(_cpu)"
				}
				if _memory > 0 {
					memory: "\(_memory)"
				}
				_container_definitions: [
					for k, container in containers {
						{
							essential: true
							name:      k
							image:     container.image
							command: [
								for v in container.command {
									v
								},
								for v in container.args {
									v
								},
							]

							environment: [
								for k, v in container.env if (v & string) != _|_ {
									name:  k
									value: v
								},
							]

							secrets: [
								for k, v in container.env if (v & v1.#Secret) != _|_ {
									name:      k
									valueFrom: v.key
								},
							]

							healthCheck: {
								command: ["CMD-SHELL", "exit 0"]
							}

							if container.resources.requests.cpu != _|_ {
								cpu: strconv.Atoi(
									strings.TrimSuffix(container.resources.requests.cpu, "m"),
									)
							}
							if container.resources.limits.cpu != _|_ {
								ulimits: [{
									name:      "cpu"
									softLimit: strconv.Atoi(
											strings.TrimSuffix(container.resources.limits.cpu, "m"),
											)
									hardLimit: strconv.Atoi(
											strings.TrimSuffix(container.resources.limits.cpu, "m"),
											)
								}]
							}
							if container.resources.requests.memory != _|_ {
								memoryReservation: strconv.Atoi(
											strings.TrimSuffix(container.resources.requests.memory, "M"),
											)
							}
							if container.resources.limits.memory != _|_ {
								memory: strconv.Atoi(
									strings.TrimSuffix(container.resources.limits.memory, "M"),
									)
							}

							logConfiguration: {
								logDriver: "awslogs"
								options: {
									"awslogs-group":         "/aws/ecs/\(clusterName)"
									"awslogs-region":        aws.region
									"awslogs-stream-prefix": appName
								}
							}
						}
					},
				]
			}
		}
	}
}

// expose an ECS service through a load balancer
#ExposeECSService: v1.#Transformer & {
	v1.#Component
	traits.#Exposable
	$metadata:  _
	containers: _
	endpoints:  _

	vpcId: string
	subnets: [...string]
	lbTargetGroupName:   string
	lbSecurityGroupName: string
	lbHost:              string
	appName:             string | *$metadata.id
	endpoints: default: host: lbHost
	$resources: terraform: schema.#Terraform & {
		data: {
			aws_lb_target_group: "\(lbTargetGroupName)": name:  lbTargetGroupName
			aws_security_group: "\(lbSecurityGroupName)": name: lbSecurityGroupName
		}
		resource: {
			aws_security_group: "\(appName)": {
				name:   appName
				vpc_id: vpcId
				ingress: [
					for p in endpoints.default.ports {
						{
							protocol:  "tcp"
							from_port: p.port
							to_port:   p.port
							security_groups: [
								"${data.aws_security_group.\(lbSecurityGroupName).id}",
							]
							description:      null
							ipv6_cidr_blocks: null
							cidr_blocks:      null
							prefix_list_ids:  null
							self:             null
						}
					},
				]
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
			aws_ecs_service: "\(appName)": _#ECSService & {
				network_configuration: {
					security_groups: [
						"${aws_security_group.\(appName).id}",
					]
					"subnets": subnets
				}
				load_balancer: [
					for k, _ in containers for p in endpoints.default.ports {
						{
							target_group_arn: "${data.aws_lb_target_group.\(lbTargetGroupName).arn}"
							container_name:   k
							container_port:   p.port
						}
					},
				]
			}
			aws_ecs_task_definition: "\(appName)": _#ECSTaskDefinition & {
				network_mode: "awsvpc"
				_container_definitions: [
					...{
						portMappings: [
							for p in endpoints.default.ports {
								{
									containerPort: p.port
								}
							},
						]
					},
				]
			}
		}
	}
}

// Add ECS service replicas
#AddECSReplicas: v1.#Transformer & {
	v1.#Component
	traits.#Replicable
	$metadata: _
	replicas:  _
	appName:   string | *$metadata.id
	$resources: terraform: schema.#Terraform & {
		resource: aws_ecs_service: "\(appName)": _#ECSService & {
			desired_count: replicas.min
		}
	}
}

_#ECSTaskDefinition: {
	family:             string
	network_mode:       *"bridge" | "host" | "awsvpc" | "none"
	execution_role_arn: string
	requires_compatibilities?: [..."EC2" | "FARGATE"]
	cpu?:           string
	memory?:        string
	task_role_arn?: string
	_container_definitions: [..._#ContainerDefinition]
	container_definitions: json.Marshal(_container_definitions)
}
_#ECSService: {
	name:            string
	cluster:         string
	task_definition: string
	desired_count:   uint | *1
	launch_type:     "EC2" | "FARGATE"
	network_configuration?: {
		security_groups: [...string]
		subnets: [...string]
	}
	load_balancer?: [...{
		target_group_arn: string
		container_name:   string
		container_port:   uint
	}]
}

#AddECS: v1.#Transformer & {
	traits.#ECS
	ecs: _
	_tags: {
		if ecs.environment != _|_ {
			environment: ecs.environment
		}
		terraform: "true"
	}
	$resources: terraform: schema.#Terraform & {
		if ecs.logging.enabled {
			resource: aws_kms_key: "ecs_\(ecs.name)": {
				description:             "ecs_\(ecs.name) log encryption key"
				deletion_window_in_days: 7
				tags:                    _tags
			}
			resource: aws_cloudwatch_log_group: "ecs_\(ecs.name)": {
				name:              "/aws/ecs/\(ecs.name)"
				retention_in_days: ecs.logging.retentionInDays
				tags:              _tags
			}
		}
		module: "ecs_\(ecs.name)": {
			source:  "terraform-aws-modules/ecs/aws"
			version: string | *"4.1.2"

			cluster_name: ecs.name
			if ecs.logging.enabled {
				cluster_configuration: execute_command_configuration: {
					kms_key_id: "${aws_kms_key.ecs_\(ecs.name).arn}"
					logging:    "OVERRIDE"

					log_configuration: {
						cloud_watch_encryption_enabled: true
						cloud_watch_log_group_name:     "${aws_cloudwatch_log_group.ecs_\(ecs.name).name}"
					}
				}
			}

			if ecs.capacityProviders.fargate.enabled {
				fargate_capacity_providers: FARGATE: default_capacity_provider_strategy: ecs.capacityProviders.fargate.defaultStrategy
			}

			if ecs.capacityProviders.fargateSpot.enabled {
				fargate_capacity_providers: FARGATE_SPOT: default_capacity_provider_strategy: ecs.capacityProviders.fargate.defaultStrategy
			}

			// autoscaling_capacity_providers: {}

			tags: _tags
		}
		output: "ecs_\(ecs.name)_cluster_id": value: "${module.ecs_\(ecs.name).cluster_id}"
	}
}
