package argocd

import (
	"encoding/yaml"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	argoapp "github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
	"strings"
)

_#ArgoCDApplicationResource: {
	$metadata: labels: {
		driver: "kubernetes"
		type:   "argoproj.io/v1alpha1/application"
		...
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
	argocd:    _
	helm: repoType: "git" | "oci" | "default"
	argocd: {
		syncWave: string | *"0"
		destination: {
			server: string | *"https://kubernetes.default.svc"
		}
		namespace?: string
	}
	$resources: "\($metadata.id)": _#ArgoCDApplicationResource & {
		metadata: {
			name:      helm.release
			// If argocd.namespace is not set, use helm.namespace
			namespace: *argocd.namespace | _
			namespace: helm.namespace | _
			finalizers: [
				"resources-finalizer.argocd.argoproj.io",
			]
			annotations: "argocd.argoproj.io/sync-wave": argocd.syncWave
		}
		spec: {
			source: {

				chart: helm.chart

				if helm.repoType == "oci" {
					repoURL: strings.TrimPrefix(helm.url, "oci://")
				}

				if helm.repoType != "oci" {
					repoURL: helm.url
				}      

				targetRevision: helm.version

				"helm": {
					releaseName: helm.release
					values:      yaml.Marshal(helm.values)
				}
			}
			destination: {
				namespace: helm.namespace
				server:    argocd.destination.server
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
