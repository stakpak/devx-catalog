package components

import (
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/k8s/services/certm/resources"
)

#SelfSignedCertifcate: {
	traits.#KubernetesResources
	k8s: _
	certIssuer: {
		name: string
		kind: "Issuer" | *"ClusterIssuer"
	}
	certificate: {
		commonName: string
		secretName: string
	}
	k8sResources: {
		"cert-self-certificate-\(certificate.commonName)": resources.#Certificate & {
			metadata: {
				name:      certificate.commonName
				namespace: k8s.namespace
			}
			spec: {
                isCA: true
				commonName: certificate.commonName
				secretName: certificate.secretName
				issuerRef: {
					name:  certIssuer.name
					kind:  certIssuer.kind
					group: "cert-manager.io"
				}
				privateKey: {
					algorithm: "ECDSA"
					size:      256
				}
			}
		}
	}
}
