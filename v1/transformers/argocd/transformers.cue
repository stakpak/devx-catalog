package argocd

import (
	"encoding/yaml"
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	argoapp "github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
)

_#ArgoCDApplicationResource: {
	$metadata: labels: {
		driver: "kubernetes"
		type:   "argoproj.io/v1alpha1/application"
	}
	argoapp.#Application
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	spec: project: string | *"default"
}

// add a helm release
#AddHelmRelease: v1.#Transformer & {
	traits.#Helm
	$metadata: _
	helm:      _
	$resources: "\($metadata.id)": _#ArgoCDApplicationResource & {
		metadata: {
			name:      $metadata.id
			namespace: helm.namespace
			finalizers: [
				"resources-finalizer.argocd.argoproj.io",
			]
		}
		spec: {
			source: {

				chart: helm.chart

				repoURL:        helm.url
				targetRevision: helm.version

				"helm": {
					releaseName: $metadata.id
					values:      yaml.Marshal(helm.values)
				}
			}
			destination: {
				namespace: helm.namespace
			}

			syncPolicy: argoapp.#SyncPolicy & {
				automated: {
					prune:      bool | *true
					selfHeal:   bool | *true
					allowEmpty: bool | *false
				}
				syncOptions: [...string] | *[
						"CreateNamespace=true",
						"PrunePropagationPolicy=foreground",
						"PruneLast=true",
				]
				retry: limit: uint | *5
			}
		}
	}
}
