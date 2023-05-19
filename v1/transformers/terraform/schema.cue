package terraform

import "guku.io/devx/v1"

#Terraform: {
	$metadata: labels: {
		driver: "terraform"
		type:   ""
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

#SetOutputSubdir: v1.#Transformer & {
	subdir: string
	$resources: [string]: $metadata: labels: "output-subdir": subdir
}
