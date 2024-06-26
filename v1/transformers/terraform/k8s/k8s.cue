package k8s

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
)

#AddKubernetesResources: v1.#Transformer & {
	traits.#KubernetesResources
	$metadata:    _
	k8sResources: _
	$resources: terraform: schema.#Terraform & {
		for name, resource in k8sResources {
			"resource": kubernetes_manifest: "\($metadata.id)_\(name)": {
				manifest: {
					resource
				}
				if $metadata.labels.force_conflicts != _|_ {
					field_manager: force_conflicts: true
				}
			}
		}
	}
}


#AddKubernetesCronJob: v1.Transformer & {
	traits.#Cronable
	traits.#Workload
	$metadata:  _
	cron:       _
	containers: _
	$resources: terraform: schema.#Terraform & {
		resource: kubernetes_cron_job_v1: "\($metadata.id)-cron-job": {
			spec: {
				concurrency_policy:        *"Allow" | "Forbid" | "Replace"
				failed_jobs_history_limit: number | *1
				schedule:                  cron.schedule
				job_template: {
					spec: {
						template: {
							spec: {
								"containers": [
									for _, container in containers {
										{
											image:   container.image
											args:    container.args
											command: container.command
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
	kubeconfig: {
		path:     string | *"~/.kube/config"
		context?: string
	}
	$resources: terraform: schema.#Terraform & {
		provider: helm: kubernetes: {
			config_path: kubeconfig.path
			if kubeconfig.context != _|_ {
				config_context: kubeconfig.context
			}
		}
	}
}

#AddLocalKubernetesProvider: v1.#Transformer & {
	kubeconfig: {
		path:     string | *"~/.kube/config"
		context?: string
	}
	$resources: terraform: schema.#Terraform & {
		provider: kubernetes: {
			config_path: kubeconfig.path
			if kubeconfig.context != _|_ {
				config_context: kubeconfig.context
			}
		}
	}
}

#AddRandomSecret: v1.#Transformer & {
	traits.#Secret
	$metadata: _

	secrets: _
	k8s: {
		namespace: string
		...
	}
	$resources: terraform: schema.#Terraform & {
		resource: {
			for _, secret in secrets {
				random_password: "secret_\(secret.name)": {
					length:  32
					special: false
				}
				kubernetes_secret_v1: {
					if secret.property != _|_ {
						"\($metadata.id)_\(secret.name)_\(secret.property)": {
							metadata: {
								namespace: k8s.namespace
								name:      secret.name
							}
							data: {
								"\(secret.property)": "${random_password.secret_\(secret.name)_\(secret.property).result}"
								...
							}
						}
					}
					if secret.property == _|_ {
						"\($metadata.id)_\(secret.name)": {
							metadata: {
								namespace: k8s.namespace
								name:      secret.name
							}
							data: {
								if secret.property != _|_ {
									"\(secret.property)": "${random_password.secret_\(secret.name).result}"
								}
								if secret.property == _|_ {
									value: "${random_password.secret_\(secret.name).result}"
								}
							}
						}
					}
				}
			}
		}
	}
}
