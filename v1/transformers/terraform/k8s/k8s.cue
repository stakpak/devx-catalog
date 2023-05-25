package k8s

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddKubernetesResources: v1.#Transformer & {
	traits.#KubernetesResources
	$metadata:    _
	k8sResources: _
	$resources: terraform: schema.#Terraform & {
		for name, resource in k8sResources {
			"resource": kubernetes_manifest: "\($metadata.id)_\(name)": manifest: {
				resource
			}
		}
	}
}

#AddIAMUserSecret: v1.#Transformer & {
	traits.#User
	$metadata: _
	users: [string]: {
		username: string
		password: name: "\(username)"
	}
	k8s: {
		namespace: string
		...
	}
	$resources: terraform: schema.#Terraform & {
		resource: kubernetes_secret_v1: {
			for _, user in users {
				"\($metadata.id)_\(user.username)": {
					metadata: {
						namespace: k8s.namespace
						name:      user.username
					}
					data: {
						"access-key":        "${aws_iam_access_key.\(user.username).id}"
						"secret-access-key": "${aws_iam_access_key.\(user.username).secret}"
					}
				}
			}
		}
	}
}

#AddLocalHelmProvider: v1.#Transformer & {
	traits.#Helm
	k8s: {
		kubeconfig: string | *"~/.kube/config"
		context?:   string
		...
	}
	$resources: terraform: schema.#Terraform & {
		provider: helm: kubernetes: {
			config_path: k8s.kubeconfig
			if k8s.context != _|_ {
				config_context: k8s.context
			}
		}
	}
}

#AddLocalKubernetesProvider: v1.#Transformer & {
	k8s: {
		kubeconfig: string | *"~/.kube/config"
		context?:   string
		...
	}
	$resources: terraform: schema.#Terraform & {
		provider: kubernetes: {
			config_path: k8s.kubeconfig
			if k8s.context != _|_ {
				config_context: k8s.context
			}
		}
	}
}
