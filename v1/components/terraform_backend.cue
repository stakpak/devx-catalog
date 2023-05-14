package components

import (
	"guku.io/devx/v1"
	schema "guku.io/devx/v1/transformers/terraform"
)

#TerraformS3Backend: v1.#Trait & {
	s3: {
		bucket: string
		key:    string
		region: string
	}
	$resources: terraform: schema.#Terraform & {
		$metadata: labels: {
			driver: "terraform"
			type:   ""
		}
		terraform: backend: "s3": {
			bucket: s3.bucket
			key:    s3.key
			region: s3.region
		}
	}
}
