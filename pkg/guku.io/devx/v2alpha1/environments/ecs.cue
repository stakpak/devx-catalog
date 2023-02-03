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
		vpc: name: string
		ecs: {
			name:       string
			launchType: string
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
				aws: {
					config.aws
					vpc: config.vpc
				}
				clusterName: config.ecs.name
				launchType:  config.ecs.launchType
			},
		]
		"terraform/expose-ecs-service": pipeline: [tfaws.#ExposeECSService]
		"terraform/add-ecs-replicas": pipeline: [tfaws.#AddECSReplicas]
		"terraform/add-ecs-http-routes": pipeline: [tfaws.#AddHTTPRouteECS]
		"terraform/add-http-route": pipeline: [tfaws.#AddHTTPRoute & {aws: vpc: config.vpc}]
	}
}
