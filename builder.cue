package main

import (
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/v1/transformers/terraform/helm"
	"stakpak.dev/devx/v1/transformers/terraform/aws"
	"stakpak.dev/devx/v1/transformers/terraform/k8s"
	"stakpak.dev/devx/v1/transformers/terraform"
	"stakpak.dev/devx/v2alpha1"
	rabbitmq "stakpak.dev/devx/k8s/services/rabbitmq/transformers/terraform/k8s"
	mongodb "stakpak.dev/devx/k8s/services/mongodb/transformers/terraform/k8s"
	eso "stakpak.dev/devx/k8s/services/eso/transformers/terraform/k8s"

)

builders: v2alpha1.#Environments & {

	"alpinecreations": #EdgeBuilder & {
		config: {
			kubeconfig: "~/.kube/alpinecreations"
		}
	}

	"muaf": #EdgeBuilder & {
		config: {
			kubeconfig: "/etc/rancher/k3s/k3s.yaml"
		}
	}

	"qiz": #EdgeBuilder & {
		config: {
			kubeconfig: "~/.kube/qiz"
		}
	}
}

#EdgeBuilder: v2alpha1.#StackBuilder & {
	environment: string
	config: {
		name:       string | *environment
		kubeconfig: string
	}
	drivers: terraform: output: dir: ["deploy", "customers", config.name]

	let terraformPlatformLayer = terraform.#SetOutputSubdir & {
		subdir: "platform"
	} & terraform.#SetS3Backend & {
		s3: {
			region: "eu-west-1"
			bucket: "garment-io-terraform-state-prod"
			key:    "garment.io/customers/\(config.name)/infrastructure/platform"
		}
	}

	let terraformResourcesLayer = terraform.#SetOutputSubdir & {
		subdir: "resources"
	} & terraform.#SetS3Backend & {
		s3: {
			region: "eu-west-1"
			bucket: "garment-io-terraform-state-prod"
			key:    "garment.io/customers/\(config.name)/infrastructure/resources"
		}
	}

	flows: {
		"ignore-k8s-cluster": pipeline: [{traits.#KubernetesCluster & {k8s: name: "<unkown>"}}]
		"ignore-redis": pipeline: [{traits.#Redis & {redis: host: "<unknown>"}}]
		"ignore-repos": pipeline: [{traits.#OCIRepository}]
		"terraform/helm": pipeline: [
			terraformPlatformLayer,
			helm.#AddHelmRelease,
			k8s.#AddLocalHelmProvider & {
				kubeconfig: path: config.kubeconfig
			},
		]
		"terraform/aws-iam": pipeline: [
			terraformResourcesLayer,
			aws.#AddIAMUser,
			aws.#AddIAMPermissions,
			k8s.#AddLocalKubernetesProvider & {
				kubeconfig: path: config.kubeconfig
			},
		]
		"terraform/aws-iam-k8s": {
			match: labels: "k8s-secret": "k8s"
			pipeline: [
				terraformResourcesLayer,
				k8s.#AddIAMUserSecret,
				k8s.#AddLocalKubernetesProvider & {
					kubeconfig: path: config.kubeconfig
				},
			]
		}
		"terraform/pullecrtoken":{
			match: labels: "k8s-secret": "ecr"
			pipeline: [
				terraformResourcesLayer,
				eso.AddECRToken,
				k8s.#AddLocalKubernetesProvider & {
					kubeconfig: path: config.kubeconfig
				},
			]
		}
		"terraform/rabbit-mq": {
			pipeline: [
				terraformResourcesLayer,
				rabbitmq.#AddCluster,
				k8s.#AddLocalKubernetesProvider & {
					kubeconfig: path: config.kubeconfig
				},
			]
		}
		"terraform/add-mongo": pipeline: [
			terraformResourcesLayer,
			mongodb.#AddDatabase,
			k8s.#AddLocalKubernetesProvider & {
				kubeconfig: path: config.kubeconfig
			},
		]
		"terraform/add-user-password": {
			match: labels: secret: "generate"
			pipeline: [
				terraformResourcesLayer,
				k8s.#AddRandomSecret,
				k8s.#AddLocalKubernetesProvider & {
					kubeconfig: path: config.kubeconfig
				},
			]
		}
		"kubernetes/k8s": pipeline: [
			terraformResourcesLayer,
			k8s.#AddKubernetesResources,
			k8s.#AddLocalKubernetesProvider & {
				kubeconfig: path: config.kubeconfig
			},
		]
		"ignore-gateway": pipeline: [{traits.#Gateway}],
	}

	taskfile: tasks: {
		check: {
			run: "once"
			preconditions: [
				{
					sh:  "terraform -h"
					msg: "terraform is not installed, make sure terraform cli is installed (check https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)"
				},
				{
					sh:  "aws sts get-caller-identity"
					msg: "unable to authenticate to your AWS account, make sure AWS cli v2 is installed (check https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and that your credentials are configured"
				},
				{
					sh:  "[ -f \(config.kubeconfig) ]"
					msg: "unable to authenticate to your Kubernetes cluster, make sure you have a valid kubeconfig file present in your environment at /etc/rancher/k3s/k3s.yaml"
				},
			]
			cmds: ["echo \"All looks good, ready to apply!\""]
		}

		let layers = ["platform", "resources"]
		for layer in layers {
			"init-\(layer)": {
				deps: ["check"]
				dir: "deploy/customers/\(config.name)/\(layer)"
				cmds: ["terraform init -upgrade"]
			}
			"apply-\(layer)": {
				env: AWS_REGION: "eu-west-1"
				deps: ["init-\(layer)"]
				dir: "deploy/customers/\(config.name)/\(layer)"
				cmds: ["terraform apply"]
			}
			"plan-\(layer)": {
				env: AWS_REGION: "eu-west-1"
				deps: ["init-\(layer)"]
				dir: "deploy/customers/\(config.name)/\(layer)"
				cmds: ["terraform plan"]
			}
			"destroy-\(layer)": {
				env: AWS_REGION: "eu-west-1"
				deps: ["init-\(layer)"]
				dir: "deploy/customers/\(config.name)/\(layer)"
				cmds: ["terraform destroy"]
			}
		}

		"init-all": {
			cmds: [
				for layer in layers {
					{
						task: "init-\(layer)"
					}
				},
			]
		}

		"apply-all": {
			cmds: [
				for layer in layers {
					{
						task: "apply-\(layer)"
					}
				},
			]
		}

		"plan-all": {
			cmds: [
				for layer in layers {
					{
						task: "plan-\(layer)"
					}
				},
			]
		}

		let reverseLayers = ["resources", "platform"]
		"destroy-all": {
			cmds: [
				for layer in reverseLayers {
					{
						task: "destroy-\(layer)"
					}
				},
			]
		}
	}
}