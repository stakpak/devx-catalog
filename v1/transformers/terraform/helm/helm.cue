package helm

import (
	"encoding/yaml"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
)

// add a helm release
#AddHelmRelease: v1.#Transformer & {
	traits.#Helm
	$metadata: _
	helm:      _
	helm: repoType:        "oci" | *"default"
	$resources: terraform: schema.#Terraform & {
		resource: helm_release: "\(helm.release)": {
			name:             helm.release
			namespace:        helm.namespace
			repository:       helm.url
			chart:            helm.chart
			version:          helm.version
			timeout:          helm.timeout
			atomic:           helm.atomic
			create_namespace: helm.createNamespace
			values: [
				yaml.Marshal(helm.values),
			]
			depends_on: [
				for item in helm.dependsOn {
					"helm_release.\(item.release)"
				},
			]
		}
	}
}
