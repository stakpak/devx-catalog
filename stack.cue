package main

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/stacks"
	esc "stakpak.dev/devx/k8s/services/eso/components"
	esh "stakpak.dev/devx/k8s/services/eso/helpers"
	// eso "stakpak.dev/devx/k8s/services/eso/transformers/terraform/k8s"
	rabbitmq "stakpak.dev/devx/k8s/services/rabbitmq"
	redisk8s "stakpak.dev/devx/k8s/services/redis"
	argocd "stakpak.dev/devx/k8s/services/argocd"
	argoapp "stakpak.dev/devx/k8s/services/argocd/components"
	kedac "stakpak.dev/devx/k8s/services/keda"
	simplemongodb "stakpak.dev/devx/k8s/services/simplemongodb"
	// imp "stakpak.dev/devx/k8s/services/imagepullsecrets"
	// impc "stakpak.dev/devx/k8s/services/imagepullsecrets/components"
	// imph "stakpak.dev/devx/k8s/services/imagepullsecrets/helpers"
)

stack: v1.#Stack & {
	components: {
		// kubernetes cluster
		cluster: {
			traits.#KubernetesCluster
			k8s: version: minor: 27
		}

		// platform services
		stacks.KubernetesBasicStack.components
		certManager: k8s:  cluster.k8s
		ingressNginx: k8s: cluster.k8s
		externalSecretsOperator: {
			k8s: cluster.k8s
			helm: version: "0.9.14"
		}
		"argo-cd": argocd.#ArgoCDChart & {
			k8s: cluster.k8s
			helm: {
				values: {
					nameOverride: "argo-cd"
					"redis-ha": enabled:          false
					controller: replicas:         1
					server: replicas:             1
					repoServer: replicas:         1
					applicationSet: replicaCount: 1
				}
			}
		}

		rabbitmqop: {
			rabbitmq.#RabbitMQOperatorChart
			k8s: cluster.k8s
		}

		keda: {
			kedac.#KEDAChart
			k8s: cluster.k8s
		}

		mainStore: {
			$metadata: labels: "k8s-secret": "k8s"
			traits.#User
			esc.#AWSSecretStore
			users: default: username: string
			policies: "secret-access": (esh.#ParameterStoreAWSIAMPolicy & {
				prefix: ""
				aws: {
					region:  "eu-west-1"
					account: "777833595077"
				}
			}).policy
			k8s: {
				cluster.k8s
				namespace: externalSecretsOperator.helm.namespace
			}
			aws: region: "eu-west-1"
			secretStore: {
				name:            "main"
				scope:           "cluster"
				type:            "ParameterStore"
				accessKeySecret: users.default.password
			}
		}

		localStore: {
			$metadata: labels: "k8s-secret": "k8s"
			esc.#KubernetesSecretStore
			k8s: cluster.k8s & {
				namespace: "default"
			}
			secretStore: {
				name: "local"
			}
		}

		queue: {
			$metadata: labels: "force_conflicts": "true"
			traits.#RabbitMQ
			k8s: cluster.k8s & {
				namespace: "default"
			}
			rabbitmq: {
				name:     "rabbitmqcluster"
				replicas: 1
				version:  "3.11-management"
			}
		}

		redis: {
			traits.#Redis
			redis: {
				version: "7.0"
			}
		}

		gateway: {
			traits.#Gateway
			gateway: {
				name:   "default"
				public: true
				listeners: {
					"http": {
						port:     80
						protocol: "HTTP"
					}
					"https": {
						port:     443
						protocol: "HTTPS"
					}
				}
			}
		}

		backendCDApplication: argoapp.#ArgoCDApplication & {
			k8s: {
				cluster.k8s
				namespace: "argo-cd"
			}
			application: {
				name: "garment-backend"
				source: {
					repoURL:        "git@github.com:INDOS-EG/garment-backend.git"
					targetRevision: string
				}
				credentials: {
					privateKey: name: "prod-backend-repo-deploy-key"
					externalSecret: {
						storeRef: {
							name: "main"
						}
					}
				}
			}
		}
		pullecrsecret: {
			traits.#ImagePullSecret
			// $metadata: labels: "k8s-secret": "ecr-credentials"
			secret: {
				provider:        "aws"
				region:          "eu-west-1"
				accessKey: { 
					name: "ecr-credentials"
					key:  "access-key"
				}
				secretAccessKey: {
					name: "ecr-credentials"
					key:  "secret-access-key"
				}
			}
			k8s: {
				cluster.k8s
				namespace: "external-secrets"
		}
	}
}
}

#EdgeBuilder: {
	config: name: string
	components: {
		cluster: _

		mainStore: users: default: username:          "main-store-customer-\(config.name)"
		redis: {
			redisk8s.#RedisChart
			k8s: cluster.k8s
			helm: {
				namespace: "default"
				values: auth: enabled: false
			}
		}
		mongo: {
			k8s: cluster.k8s
			simplemongodb.#SimpleMongoDBChart & {
				helm: {
					namespace: "default"
					values: {
						livenessProbe: {
  							timeoutSeconds: 60
						}
						readinessProbe: { 
  							timeoutSeconds: 60
						}
						architecture: "replicaset"
						persistence: size: "30Gi"
						resources: {
							limits:{
								cpu: "5120m"
								memory: "12Gi"
							}
							requests: {
								cpu: "2048m"
								memory: "8Gi"
							}
						}
					}
				}
			}
		}

		metabase: {
			traits.#Helm
			k8s: cluster.k8s
			helm: {
				repoType:  "default"
				url:       "https://pmint93.github.io/helm-charts"
				chart:     "metabase"
				version:   "2.16.7"
				namespace: "metabase"
				values: {
					ingress: {
						enabled: true
						hosts: [
							"metabase.garmentio.premise"
						]
						className: "nginx"
					}
				}
			}
		}

		backendCDApplication: application: source: {
			path:           "deploy/build/edge"
			targetRevision: "master"
		}

		frontendCDApplication: argoapp.#ArgoCDApplication & {
			k8s: {
				cluster.k8s
				namespace: "argo-cd"
			}
			application: {
				name: "garment-frontend"
				source: {
					repoURL: "git@github.com:INDOS-EG/garment-frontend.git"
					path:    "deploy/build/edge"
				}
				credentials: {
					privateKey: name: "prod-frontend-repo-deploy-key"
					externalSecret: {
						storeRef: {
							name: "main"
						}
					}
				}
			}
		}

		displaysCDApplication: argoapp.#ArgoCDApplication & {
			k8s: {
				cluster.k8s
				namespace: "argo-cd"
			}
			application: {
				name: "garment-displays"
				source: {
					repoURL: "git@github.com:INDOS-EG/garment-displays.git"
					path:    "deploy/build/edge"
				}
				credentials: {
					privateKey: name: "prod-displays-repo-deploy-key"
					externalSecret: {
						storeRef: {
							name: "main"
						}
					}
				}
			}
		}
	}
}