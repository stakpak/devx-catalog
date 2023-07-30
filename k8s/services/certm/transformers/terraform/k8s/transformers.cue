package k8s

import (
	"stakpak.dev/devx/v1"
	schema "stakpak.dev/devx/v1/transformers/terraform"
	resources "stakpak.dev/devx/k8s/services/certm/resources"
)

#AddCertIssuer: v1.#Transformer & {
	$metadata: _

	k8s: {
		namespace: string
		...
	}

	certIssuer: {
		name: string | *"letsencrypt"
		server: string | *"https://acme-v02.api.letsencrypt.org/directory"
		email:  string
		privateKeySecretRefName: string | *"letsencrypt"
	}

	$resources: terraform: schema.#Terraform & {
		resource: kubernetes_manifest: {
			"\($metadata.id)-cert-issuer": manifest: resources.#Issuer & {
				metadata: {
					name:      certIssuer.name
					namespace: k8s.namespace
				}
				spec: {
					acme: {
						server: certIssuer.server
						email:  certIssuer.email
						privateKeySecretRef: name: certIssuer.privateKeySecretRefName
						solvers:[
							{
								http01: {
									ingress: {
										ingressClassName: "nginx"
									}
								}
							}
						]
					}
				}
			}
		}
	}
}
