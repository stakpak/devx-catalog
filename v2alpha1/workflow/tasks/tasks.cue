package tasks

import (
	// "strings"
	"guku.io/devx/v1"
	"guku.io/devx/v2alpha1/traits"
)

#BuildPushECR: traits.#WorkflowTask & {
	$metadata: task: "BuildPushECR"

	registry:   string | *""
	repository: string
	tags: [...string]
	context: string | *"."
	file:    string | *"\(context)/Dockerfile"
	buildArgs: [string]: string | v1.#Secret
	aws: {
		region:           string
		public:           bool | *false
		account?:         string | v1.#Secret
		role?:            string
		session?:         string
		accessKeyId?:     string | v1.#Secret
		accessKeySecret?: string | v1.#Secret
	}

	// if aws.public {
	//  registry: strings.MinRunes(1)
	// }
	// if !aws.public {
	//  aws: account: string | v1.#Secret
	// }
}

#RawTask: traits.#WorkflowTask & {
	$metadata: task: "RawTask"
	spec: [string]:  _
}

#Terraform: traits.#WorkflowTask & {
	$metadata: task: "Terraform"

	dir:     string
	show:    bool | *true
	apply:   bool | *false
	version: string | *"1.4.2"
	auth: {
		aws?: {
			region:           string
			role?:            string
			session?:         string
			accessKeyId?:     string | v1.#Secret
			accessKeySecret?: string | v1.#Secret
		}
	}
}
