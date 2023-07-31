package components

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/certm/resources"
)

#ClusterIssuer: {
	traits.#KubernetesResources
	certIssuer: {
		name:                    string | *"letsencrypt"
		server:                  string | *"https://acme-v02.api.letsencrypt.org/directory"
		email:                   string
		privateKeySecretRefName: string | *"letsencrypt"
		ingressClass:            string | *"nginx"

		dnsSolvers: [...{
			selector: dnsZones: [...string]
			route53?: {
				region:          string
				accessKeySecret: v1.#Secret
				role?:           string
			}
		}]
	}

	k8sResources: "cert-issuer-\(certIssuer.name)": resources.#ClusterIssuer & {
		metadata: {
			name: certIssuer.name
		}
		spec: acme: {
			email:  certIssuer.email
			server: certIssuer.server
			privateKeySecretRef: {
				name: certIssuer.privateKeySecretRefName
			}
			solvers: [
				{
					http01: {
						ingress: {
							class: certIssuer.ingressClass
						}
					}
				},

				for solver in certIssuer.dnsSolvers {
					{
						selector: solver.selector
						dns01: {
							if solver.route53 != _|_ {
								route53: {
									region: solver.region
									accessKeyIDSecretRef: {
										name: solver.route53.accessKeySecret.name
										key:  "access-key"
									}
									secretAccessKeySecretRef: {
										name: solver.route53.accessKeySecret.name
										key:  "secret-access-key"
									}
								}
							}
						}
					}
				},
			]
		}
	}
}
