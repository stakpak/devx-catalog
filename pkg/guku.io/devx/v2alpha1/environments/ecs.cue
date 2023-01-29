package environments

import (
	"guku.io/devx/v2alpha1"
	tfaws "guku.io/devx/v1/transformers/terraform/aws"
)

#ECS: v2alpha1.#StackBuilder & {
	$metadata: builder: "ECS"

	config: {
		aws: {
			region:  string
			account: string
		}
		vpc: {
			id: string
			subnets: [...string]
		}
		lb: {
			host:              string
			securityGroupName: string
			targetGroupName:   string
		}
		ecs: {
			clusterName: string
			launchType:  string
		}
		secrets: {
			service: *"ParameterStore" | "SecretsManager"
		}
	}

	flows: {
		if config.secrets.service == "SecretsManager" {
			"add-secretmanager-key": pipeline: [
				tfaws.#AddSecretManagerKey & {
					aws: config.aws
				},
			]
		}
		if config.secrets.service == "ParameterStore" {
			"add-ssm-secret-key": pipeline: [
				tfaws.#AddSSMSecretKey & {
					aws: config.aws
				},
			]
		}
		"terraform/add-ecs-service": pipeline: [
			tfaws.#AddECSService & {
				aws:         config.aws
				clusterName: config.ecs.clusterName
				launchType:  config.ecs.launchType
			},
		]
		"terraform/expose-ecs-service": pipeline: [
			tfaws.#ExposeECSService & {
				vpcId:               config.vpc.id
				subnets:             config.vpc.subnets
				lbHost:              config.lb.host
				lbSecurityGroupName: config.lb.securityGroupName
				lbTargetGroupName:   config.lb.targetGroupName
			},
		]
		"terraform/add-ecs-replicas": pipeline: [tfaws.#AddECSReplicas]
	}
}
