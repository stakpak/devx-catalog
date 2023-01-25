package helm

import (
	"encoding/yaml"
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

// add a helm release
#AddHelmRelease: v1.#Transformer & {
	traits.#Helm
	$metadata: _
	helm:      _
	$resources: terraform: schema.#Terraform & {
		resource: helm_release: "\($metadata.id)": {
			name:             $metadata.id
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
					"helm_release.\(item.$metadata.id)"
				},
			]
		}
	}
}
