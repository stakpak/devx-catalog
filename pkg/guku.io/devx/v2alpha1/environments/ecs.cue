package environments

import (
	"guku.io/devx/v2alpha1"
	"guku.io/devx/v1/traits"
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
		gateway?: {
			traits.#Gateway
		}
	}

	components: {
		if config.gateway != _|_ {
			gateway:  config.gateway
			[string]: this={
				if this.http != _|_ {
					http: "gateway": gateway
				}
			}
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
			"add-ssm-secret-value": {
				match: labels: secrets: "create"
				pipeline: [
					tfaws.#AddSSMSecretParameter,
				]
			}
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
