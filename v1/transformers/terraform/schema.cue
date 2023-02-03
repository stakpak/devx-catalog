package terraform

#Terraform: {
	$metadata: labels: {
		driver: "terraform"
		type:   ""
	}
	data?: [string]: {
		...
	}
	provider?: [string]: _
	module?: [string]:   _
	resource?: [string]: {
		...
	}
	output?: [string]: value: _
}
