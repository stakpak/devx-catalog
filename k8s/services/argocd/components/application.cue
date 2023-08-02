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
		name:    string | *"argocd-application"
		server:  string | *"https://kubernetes.default.svc"
		project: string | *"default"
		source: {
			repoURL:         string
			path?:           string
			targetRevision?: string
		}
	}

	k8sResources: "argocd-application-\(application.name)": resources.#Application & {
		metadata: {
			name:      application.name
			namespace: k8s.namespace
		}
		spec: {
			destination: {
				namespace: k8s.namespace
				server:    application.server
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