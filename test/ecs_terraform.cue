package main

import (
	"encoding/json"
	"guku.io/devx/v1"
	resources "guku.io/devx/v1/resources/aws"
	"guku.io/devx/v1/transformers/terraform/aws"
)

_addService: v1.#TestCase & {
	$metadata: test: "add service"
	transformer: aws.#AddECSService & {
		clusterName: "mycluster"
		launchType:  "FARGATE"
	}

	input: {
		$metadata: id: "obi"
		containers: default: {
			image: "hashicorp/http-echo"
			args: ["-text", "hello world"]
			resources: {
				requests: {
					cpu:    "256m"
					memory: "512M"
				}
			}
			env: {
				ENV: "prod"
				SEC: v1.#Secret & {
					name: "arn:aws:secretsmanager:balabzio"
				}
			}
		}
	}
	output: _

	expect: {
		$resources: terraform: {
			data: aws_ecs_cluster: "mycluster": cluster_name: "mycluster"

			resource: {
				aws_iam_role: "task_execution_obi": {
					name:               "task-execution-mycluster-obi"
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
				aws_iam_role_policy: "task_execution_obi_default": {
					name:   "task-execution-mycluster-obi-default"
					role:   "${aws_iam_role.task_execution_obi.name}"
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
									]
									Resource: [
										"arn:aws:secretsmanager:balabzio",
									]
								}]
						})
				}
				aws_ecs_service: "obi": {
					name:            "obi"
					cluster:         "${data.aws_ecs_cluster.mycluster.id}"
					task_definition: "${aws_ecs_task_definition.obi.arn}"
					launch_type:     "FARGATE"
				}
				aws_ecs_task_definition: "obi": {
					family:       "mycluster-obi"
					network_mode: "awsvpc"
					requires_compatibilities: ["FARGATE"]
					execution_role_arn:    "${aws_iam_role.task_execution_obi.arn}"
					cpu:                   "256"
					memory:                "512"
					container_definitions: json.Marshal([{
						essential:         true
						name:              "default"
						image:             "hashicorp/http-echo"
						cpu:               256
						memoryReservation: 512
						command: ["-text", "hello world"]
						environment: [{
							name:  "ENV"
							value: "prod"
						}]
						secrets: [{
							name:      "SEC"
							valueFrom: "arn:aws:secretsmanager:balabzio"
						}]
						healthCheck: {
							command: ["CMD-SHELL", "exit 0"]
						}
					}])
				}
			}
		}
	}
	assert: {}
}

_exposeService: v1.#TestCase & {
	$metadata: test: "expose service"
	transformer: aws.#ExposeECSService & {
		vpcId: "vpc-1"
		subnets: [
			"subnet-1",
		]
		lbHost:              "demo-1.us-west-1.elb.amazonaws.com"
		lbSecurityGroupName: "alb-sg"
		lbTargetGroupName:   "alb-tg"
	}

	input: {
		$metadata: id: "obi"
		containers: default: {
			image: "hashicorp/http-echo"
			args: ["-text", "hello world"]
			resources: {
				requests: {
					cpu:    "256"
					memory: "512"
				}
			}
		}
		endpoints: default: ports: [
			{
				port: 5678
			},
		]
	}
	output: _
	expect: {
		endpoints: default: host: "demo-1.us-west-1.elb.amazonaws.com"
		$resources: terraform: {
			data: {
				aws_lb_target_group: "alb-tg": name: "alb-tg"
				aws_security_group: "alb-sg": name:  "alb-sg"
			}
			resource: {
				aws_security_group: "obi": {
					name:   "obi"
					vpc_id: "vpc-1"
					ingress: [{
						protocol:  "tcp"
						from_port: 5678
						to_port:   5678
						security_groups: [
							"${data.aws_security_group.alb-sg.id}",
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
				aws_ecs_service: "obi": {
					network_configuration: {
						security_groups: [
							"${aws_security_group.ecs_service_internal_obi.id}",
							"${aws_security_group.obi.id}",
						]
						subnets: [
							"subnet-1",
						]
					}
					load_balancer: [{
						target_group_arn: "${data.aws_lb_target_group.alb-tg.arn}"
						container_name:   "default"
						container_port:   5678
					}]
				}
				aws_ecs_task_definition: "obi": {
					network_mode:          "awsvpc"
					container_definitions: json.Marshal([{
						portMappings: [
							{
								containerPort: 5678
							},
						]
					}])
				}
			}
		}
	}
	assert: {}
}

_addServiceReplicas: v1.#TestCase & {
	$metadata: test: "ass service replicas"
	transformer: aws.#AddECSReplicas

	input: {
		$metadata: id: "obi"
		replicas: min: 3
	}
	output: _

	expect: {
		$resources: terraform: resource: aws_ecs_service: "obi": desired_count: 3
	}
}
