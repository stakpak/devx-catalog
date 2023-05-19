package terraform

import "guku.io/devx/v1"

#Terraform: {
	$metadata: labels: {
		driver: "terraform"
		type:   ""
		...
	}
	data?: [string]: {
		...
	}
	provider?: [string]:  _
	terraform?: [string]: _
	module?: [string]:    _
	resource?: [string]: {
		...
	}
	output?: [string]: value: _
}

#SetS3Backend: v1.#Transformer & {
	s3: {
		region: string
		bucket: string
		key:    string
	}
	$resources: terraform: #Terraform & {
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

#SetOutputSubdir: v1.#Transformer & {
	subdir: string
	$resources: [string]: $metadata: labels: "output-subdir": subdir
}
