package components

import (
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/argocd/resources"
)

#ArgoCDApplication: {
	traits.#KubernetesResources
	k8s: {
		namespace: string
		...
	}
	application: {
		name:    string | *"application"
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
	}
	k8sResources: "argocd-\(application.name)": resources.#Application & {
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
				repoURL:         application.source.repoURL
				path?:           application.source.path
				targetRevision?: application.source.targetRevision
				chart?:          application.source.chart
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
}
