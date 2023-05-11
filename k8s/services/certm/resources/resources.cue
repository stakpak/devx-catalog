package resources

import (
	"guku.io/devx/v1"
)

#ClusterIssuer: v1.#Trait & {
	$metadata: traits: ClusterIssuer: null
	cert: {
		name!:      string
		email!:     string
		production: bool | *false
		solvers: http01: {
			ingressClass: string
			serviceType:  "ClusterIP"
		}
	}
}

#AddKubernetesClusterIssuer: v1.#Transformer & {
	#ClusterIssuer
	cert:      _
	$metadata: _
	$resources: "\($metadata.id)": {
		$metadata: labels: {
			driver: "kubernetes"
			type:   "cert-manager.io/v1/clusterissuer"
		}
		apiVersion: "cert-manager.io/v1"
		kind:       "ClusterIssuer"
		metadata: name: "letsencrypt-\(cert.name)"
		spec: {
			acme: {
				email: cert.email
				if !cert.production {
					server: "https://acme-staging-v02.api.letsencrypt.org/directory"
				}
				if cert.production {
					server: "https://acme-v02.api.letsencrypt.org/directory"
				}

				privateKeySecretRef: name: "\(cert.name)-issuer-account-key"

				solvers: [
					{
						http01: {
							ingress: {
								class:       cert.solvers.http01.ingressClass
								serviceType: "ClusterIP"
							}
						}
					},
					...,
				]
			}
		}
	}
}
