package resources

import (
	"stakpak.dev/devx/k8s"
	"github.com/cert-manager/cert-manager/pkg/apis/certmanager/v1"
)

#CertificateRequest: {
	k8s.#KubernetesResource
	v1.#CertificateRequest
	apiVersion: "cert-manager.io/v1"
	kind:       "CertificateRequest"
}
#Certificate: {
	k8s.#KubernetesResource
	v1.#Certificate
	apiVersion: "cert-manager.io/v1"
	kind:       "Certificate"
}
#ClusterIssuer: {
	k8s.#KubernetesResource
	v1.#ClusterIssuer
	apiVersion: "cert-manager.io/v1"
	kind:       "ClusterIssuer"
	spec: acme: preferredChain: "ISRG Root X1"
}

#Issuer: {
	k8s.#KubernetesResource
	v1.#Issuer
	apiVersion: "cert-manager.io/v1"
	kind:       "Issuer"
	spec: acme: preferredChain: "ISRG Root X1"
}

#SelfSignedClusterIssuer: {
	k8s.#KubernetesResource
	v1.#ClusterIssuer
	apiVersion: "cert-manager.io/v1"
	kind:       "ClusterIssuer"
	spec: selfSigned: {}
}

// #ClusterIssuer: v1.#Trait & {
// 	$metadata: traits: ClusterIssuer: null
// 	cert: {
// 		name!:      string
// 		email!:     string
// 		production: bool | *false
// 		solvers: http01: {
// 			ingressClass: string
// 			serviceType:  "ClusterIP"
// 		}
// 	}
// }

// #AddKubernetesClusterIssuer: v1.#Transformer & {
// 	#ClusterIssuer
// 	cert:      _
// 	$metadata: _
// 	$resources: "\($metadata.id)": {
// 		$metadata: labels: {
// 			driver: "kubernetes"
// 			type:   "cert-manager.io/v1/clusterissuer"
// 		}
// 		apiVersion: "cert-manager.io/v1"
// 		kind:       "ClusterIssuer"
// 		metadata: name: "letsencrypt-\(cert.name)"
// 		spec: {
// 			acme: {
// 				email: cert.email
// 				if !cert.production {
// 					server: "https://acme-staging-v02.api.letsencrypt.org/directory"
// 				}
// 				if cert.production {
// 					server: "https://acme-v02.api.letsencrypt.org/directory"
// 				}

// 				privateKeySecretRef: name: "\(cert.name)-issuer-account-key"

// 				solvers: [
// 					{
// 						http01: {
// 							ingress: {
// 								class:       cert.solvers.http01.ingressClass
// 								serviceType: "ClusterIP"
// 							}
// 						}
// 					},
// 					...,
// 				]
// 			}
// 		}
// 	}
// }
