package components

import (
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/certm/resources"
)

#K8sClusterCertIssuer: {
	traits.#KubernetesResources

	certIssuer: {
		name:                    string | *"letsencrypt"
		server:                  string | *"https://acme-v02.api.letsencrypt.org/directory"
		email:                   string
		privateKeySecretRefName: string | *"letsencrypt"
        ingressClass:            string | *"nginx"
	}

	k8sResources: "cert-issuer-\(certIssuer.name)": resources.#ClusterIssuer & {
		metadata: {
			name:      certIssuer.name
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
			]
		}
	}
}
