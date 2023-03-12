package tasks

import (
	"guku.io/devx/v1"
	"guku.io/devx/v2alpha1/traits"
)

#BuildPushECR: traits.#WorkflowTask & {
	$metadata: task: "BuildPushECR"

	image: string
	tags: [...string]
	context: string | *"."
	dir:     string | *"."
	aws: {
		region:           string
		public:           bool | *false
		role?:            string
		session?:         string
		accessKeyId?:     string | v1.#Secret
		accessKeySecret?: string | v1.#Secret
	}
}
