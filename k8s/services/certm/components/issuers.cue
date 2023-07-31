package components

import (
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/certm/resources"
)

#K8sCertIssuer: {
	traits.#KubernetesResources

	k8s: {
		namespace: string
		...
	}

	certIssuer: {
		name:                    string | *"letsencrypt"
		server:                  string | *"https://acme-v02.api.letsencrypt.org/directory"
		email:                   string
		privateKeySecretRefName: string | *"letsencrypt"
	}

	k8sResources: "cert-issuer-\(certIssuer.name)": resources.#Issuer & {
		metadata: {
			name:      certIssuer.name
			namespace: k8s.namespace
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
                            class: "nginx"
                        }
                    }
                }
            ]
		}
	}
}
