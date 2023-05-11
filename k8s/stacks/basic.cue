package stacks

import (
	"guku.io/devx/v1"
	"guku.io/devx/k8s/services/eso"
	"guku.io/devx/k8s/services/certm"
	"guku.io/devx/k8s/services/ingressnginx"
)

KubernetesBasicStack: v1.#Stack & {
	$metadata: stack: "KubernetesBasicStack"
	components: {
		externalSecretsOperator: eso.#ExternalSecretsOperatorChart & {
			helm: {
				version: "0.6.10"
				release: "external-secrets"
				values: {
					scopedNamespace:              ""
					scopedRBAC:                   false
					processClusterExternalSecret: true
					processClusterStore:          true
					podDisruptionBudget: {
						enabled:      false
						minAvailable: 1
					}
				}
			}
		}
		certManager: certm.#CertManagerChart & {
			helm: {
				version: "1.8.0"
				release: "cert-manager"
				values: installCRDs: true
			}
		}
		ingressNginx: ingressnginx.#IngressNginxChart & {
			helm: {
				version: "4.0.5"
				release: "ingress-nginx"
				dependsOn: [
					certManager.helm,
				]

				values: {
					controller: {
						podSecurityContext: runAsNonRoot: true
						service: {
							enableHttp:  true
							enableHttps: true
						}
					}
				}
			}
		}
	}
}
