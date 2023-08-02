package components

import (
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/argocd/resources"
	"github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
)

#ArgoCDApplication: {
	traits.#KubernetesResources
	k8s: {
		namespace: string
		...
	}
	application: {
		name: string | *"application"
		project: string | *"default"
		source: {
			repoURL:         string
			path?:           string
			targetRevision?: string
		}
		destination: {
			server:     string | *"https://kubernetes.default.svc"
			namespace:  string | *"default"
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
			source:  v1alpha1.#ApplicationSource & {
				repoURL:         application.source.repoURL
				path?:           application.source.path
				targetRevision?: application.source.targetRevision
			}
		}
	}
}
