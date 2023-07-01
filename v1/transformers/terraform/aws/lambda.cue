package aws

import (
	"strings"
	"encoding/json"
	"strconv"
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	resources "guku.io/devx/v1/resources/aws"
	schema "guku.io/devx/v1/transformers/terraform"
)

// add a Lambda function using a container image
#AddLambda: v1.#Transformer & {
	traits.#Workload
	$metadata:  _
	containers: _

	aws: {
		region:  string
		account: string
		// vpc: {
		// 	name: string
		// 	...
		// }
		...
	}
	appName: string | *$metadata.id
	$resources: terraform: schema.#Terraform & {
		data: {
			// aws_vpc: "\(aws.vpc.name)": tags: Name: aws.vpc.name
			// aws_subnets: "\(aws.vpc.name)": {
			// 	filter: [
			// 		{
			// 			name: "vpc-id"
			// 			values: ["${data.aws_vpc.\(aws.vpc.name).id}"]
			// 		},
			// 		{
			// 			name: "mapPublicIpOnLaunch"
			// 			values: ["false"]
			// 		},
			// 	]
			// }
			aws_kms_alias: "\(appName)": {
				name: "alias/lambda/\(appName)"
			}
			aws_cloudwatch_log_group: "\(appName)": {
				name: "/aws/lambda/\(appName)"
			}
		}
		resource: {
			aws_iam_role: "lambda_\(appName)": {
				name:               "lambda-\(appName)"
				assume_role_policy: json.Marshal(resources.#IAMPolicy &
					{
						Version: "2012-10-17"
						Statement: [{
							Sid:    "Lambda"
							Effect: "Allow"
							Principal: Service: "lambda.amazonaws.com"
							Action: "sts:AssumeRole"
						}]
					})
			}
			aws_iam_role_policy: "lambda_\(appName)_default": {
				name:   "lambda-\(appName)-default"
				role:   "${aws_iam_role.lambda_\(appName).name}"
				policy: json.Marshal(resources.#IAMPolicy &
					{
						Version: "2012-10-17"
						Statement: [
							{
								Effect: "Allow"
								Action: [
									"logs:DescribeLogGroups",
								]
								Resource: "*"
							},
							{
								Effect: "Allow"
								Action: [
									"logs:CreateLogStream",
									"logs:DescribeLogStreams",
									"logs:PutLogEvents",
								]
								Resource: "${data.aws_cloudwatch_log_group.\(appName).arn}"
							},
							{
								Sid:    "SSMDecrypt"
								Effect: "Allow"
								Action: [
									"kms:Decrypt",
								]
								Resource: "${data.aws_kms_alias.\(appName).target_key_arn}"
							},
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
								Sid:    "LambdaSecret"
								Effect: "Allow"
								Action: [
									"ssm:GetParameters",
									"secretsmanager:GetSecretValue",
									"kms:Decrypt",
								]
								let arns = {
									for _, v in containers.default.env if (v & v1.#Secret) != _|_ {
										if strings.HasPrefix(v.key, "arn:aws:secretsmanager:") {
											"arn:aws:secretsmanager:\(aws.region):\(aws.account):secret:\(v.name)-??????": null
										}
										if strings.HasPrefix(v.key, "arn:aws:ssm:") {
											"\(v.key)": null
										}
									}
								}
								Resource: [
									"arn:aws:kms:\(aws.region):\(aws.account):key/*",
									for arn, _ in arns {arn},
								]
							},
						]
					})
			}

			resource: aws_lambda_function: "\(appName)": {
				function_name: appName
				image_uri:     containers.default.image
				role:          "${aws_iam_role.lambda_\(appName).arn}"

				if containers.default.resources.requests.memory != _|_ {
					memory_size: strconv.Atoi(strings.TrimSuffix(containers.default.resources.requests.memory, "M"))
				}

				environment: variables: {
					for k, v in containers.default.env {
						if (v & string) != _|_ {
							"\(k)": v
						}
					}
				}
				// vpc_config: {
				// 	subnet_ids: "${data.aws_subnets.\(aws.vpc.name).ids}"
				// 	security_group_ids: [aws_security_group.example.id]
				// }
			}
		}
	}
}
