package components

import (
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/k8s/services/argocd/resources"
	eso "stakpak.dev/devx/k8s/services/eso/resources"
)

#ArgoCDApplication: {
	traits.#KubernetesResources
	k8s: {
		namespace: string
		...
	}
	application: {
		name:    string
		project: string | *"default"
		source: {
			repoURL:         string
			path?:           string
			targetRevision?: string
			chart?:          string
		}
		destination: {
			server:    string | *"https://kubernetes.default.svc"
			namespace: string | *"default"
		}
		syncPolicy: {
			automated: {
				prune:    bool | *true
				selfHeal: bool | *true
			}
			syncOptions: [...string] | *["CreateNamespace=true"]
		}
		credentials: {
			privateKey?: v1.#Secret
			externalSecret: {
				refreshInterval: *"1h" | string
				storeRef: {
					name: string
					kind: *"ClusterSecretStore" | "SecretStore"
				}
				decodingStrategy: *"None" | "Base64" | "Base64URL" | "Auto"
			}
		}
	}

	k8sResources: {
		"argocd-\(application.name)": resources.#Application & {
			metadata: {
				name:      application.name
				namespace: k8s.namespace
			}
			spec: {
				destination: {
					namespace: application.destination.namespace
					server:    application.destination.server
				}
				project: application.project
				source: {
					repoURL: application.source.repoURL
					if application.source.path != _|_ {
						path: application.source.path
					}
					if application.source.targetRevision != _|_ {
						targetRevision: application.source.targetRevision
					}
					if application.source.chart != _|_ {
						chart: application.source.chart
					}
				}
				syncPolicy: {
					automated: {
						prune:    application.syncPolicy.automated.prune
						selfHeal: application.syncPolicy.automated.selfHeal
					}
					syncOptions: application.syncPolicy.syncOptions
				}
			}
		}
		if application.credentials.privateKey != _|_ {
			"argocd-\(application.name)-external-secret": eso.#ExternalSecret & {
				metadata: {
					name:      "\(application.name)-repo-secret"
					namespace: k8s.namespace
				}
				spec: {
					refreshInterval: application.credentials.externalSecret.refreshInterval
					secretStoreRef: {
						name: application.credentials.externalSecret.storeRef.name
						kind: application.credentials.externalSecret.storeRef.kind
					}
					template: {
						stringData: {
							name: application.name
							type: "git"
							url:  application.source.repoURL
						}
					}
					data: [
						{
							secretKey: "sshPrivateKey"
							remoteRef: {
								key: application.credentials.privateKey.name
								if application.credentials.privateKey.property != _|_ {
									property: application.credentials.privateKey.property
								}
								version:          application.credentials.privateKey.version | *"latest"
								decodingStrategy: application.credentials.externalSecret.decodingStrategy
							}
						},
					]
				}
			}
		}
	}
}
