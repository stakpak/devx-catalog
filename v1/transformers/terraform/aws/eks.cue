package aws

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
)

#AddKubernetesCluster: v1.#Transformer & {
	traits.#KubernetesCluster
	k8s: _
	k8s: version: major: 1
	k8s: version: minor: uint & <=28 & >=24

	aws: {
		region: string
		vpc: {
			name: string
			...
		}

		providerVersion: string | *"5.32.1"
		tags: {
			"karpenter.sh/discovery": k8s.name
		}
		...
	}

	eks: {
		moduleVersion: string | *"19.21.0"
		instanceType:  string | *"t3.xlarge"
		minSize:       uint | *2
		maxSize:       uint | *5
		desiredSize:   uint | *2
		public:        bool | *true
	}

	irsa: {
		moduleVersion: string | *"5.32.0"
	}

	$resources: terraform: schema.#Terraform & {
		terraform: {
			required_providers: {
				"aws": {
					source:  "hashicorp/aws"
					version: aws.providerVersion
				}
			}
		}
		provider: {
			"aws": {
				region: aws.region
			}
		}
		data: {
			aws_vpc: "\(aws.vpc.name)": tags: Name: aws.vpc.name
			aws_subnets: "\(aws.vpc.name)_private": {
				filter: [
					{
						name: "vpc-id"
						values: ["${data.aws_vpc.\(aws.vpc.name).id}"]
					},
					{
						name: "mapPublicIpOnLaunch"
						values: ["false"]
					},
				]
			}
		}

		module: "\(k8s.name)": {
			source:  "terraform-aws-modules/eks/aws"
			version: eks.moduleVersion

			cluster_name:    k8s.name
			cluster_version: "\(k8s.version.major).\(k8s.version.minor)"

			cluster_endpoint_public_access: eks.public

			vpc_id:     "${data.aws_vpc.\(aws.vpc.name).id}"
			subnet_ids: "${data.aws_subnets.\(aws.vpc.name)_private.ids}"
			// control_plane_subnet_ids: module.vpc.intra_subnets

			eks_managed_node_groups: {
				default: {
					iam_role_name:            "node-\(k8s.name)"
					iam_role_use_name_prefix: false
					iam_role_additional_policies: {
						AmazonSSMManagedInstanceCore: "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
					}

					ami_type: "BOTTLEROCKET_x86_64"
					platform: "bottlerocket"

					min_size:     eks.minSize
					max_size:     eks.maxSize
					desired_size: eks.desiredSize

					instance_types: [eks.instanceType]
				}
			}

			tags: aws.tags
		}

		module: {
			cert_manager_irsa_role: {
				source:  "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
				version: irsa.moduleVersion

				role_name:                  "cert-manager"
				attach_cert_manager_policy: true
				cert_manager_hosted_zone_arns: ["arn:aws:route53:::hostedzone/Z02801112OAJQ6IQWS1U5"]

				oidc_providers: {
					ex: {
						provider_arn: "${module.\(k8s.name).oidc_provider_arn}"
						namespace_service_accounts: ["kube-system:cert-manager"]
					}
				}

				tags: aws.tags
			}
			external_secrets_irsa_role: {
				source:  "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
				version: irsa.moduleVersion

				role_name:                      "secret-store"
				attach_external_secrets_policy: true
				external_secrets_ssm_parameter_arns: ["arn:aws:ssm:*:*:parameter/\(k8s.name)-*"]

				oidc_providers: {
					ex: {
						provider_arn: "${module.\(k8s.name).oidc_provider_arn}"
						namespace_service_accounts: ["external-secrets:secret-store"]
					}
				}

				tags: aws.tags
			}
		}
	}
}

#AddHelmProvider: v1.#Transformer & {
	traits.#Helm
	k8s: {
		name: string
		...
	}
	aws: {
		region:          string
		providerVersion: string | *"5.32.1"
		...
	}

	$resources: terraform: schema.#Terraform & {
		terraform: {
			required_providers: {
				"aws": {
					source:  "hashicorp/aws"
					version: aws.providerVersion
				}
				helm: {
					source:  "hashicorp/helm"
					version: string | *"2.12.1"
				}
			}
		}
		provider: {
			"aws": {
				region: aws.region
			}
			helm: kubernetes: {
				host:                   "${data.aws_eks_cluster.cluster.\(k8s.name).endpoint}"
				token:                  "${data.aws_eks_cluster_auth.\(k8s.name).token}"
				cluster_ca_certificate: "${base64decode(data.aws_eks_cluster.\(k8s.name).certificate_authority.0.data)}"
			}
		}

		data: {
			aws_eks_cluster: "\(k8s.name)": name:      k8s.name
			aws_eks_cluster_auth: "\(k8s.name)": name: k8s.name
		}
	}
}

#AddKubernetesProvider: v1.#Transformer & {
	k8s: {
		name: string
		...
	}
	aws: {
		region:          string
		providerVersion: string | *"5.32.1"
		...
	}

	$resources: terraform: schema.#Terraform & {
		terraform: {
			required_providers: {
				"aws": {
					source:  "hashicorp/aws"
					version: aws.providerVersion
				}
				kubernetes: {
					source:  "hashicorp/kubernetes"
					version: string | *"2.24.0"
				}
			}
		}
		provider: {
			"aws": {
				region: aws.region
			}
			kubernetes: {
				host:                   "${data.aws_eks_cluster.cluster.\(k8s.name).endpoint}"
				token:                  "${data.aws_eks_cluster_auth.\(k8s.name).token}"
				cluster_ca_certificate: "${base64decode(data.aws_eks_cluster.\(k8s.name).certificate_authority.0.data)}"
			}
		}

		data: {
			aws_eks_cluster: "\(k8s.name)": name:      k8s.name
			aws_eks_cluster_auth: "\(k8s.name)": name: k8s.name
		}
	}
}
