package triggers

import (
	"guku.io/devx/v2alpha1/traits"
)

#PushEvent: traits.#WorkflowTrigger & {
	$metadata: trigger: "PushEvent"
	filters: {
		branches: [...string]
		...
	}
}

#PullRequestEvent: traits.#WorkflowTrigger & {
	$metadata: trigger: "PullRequestEvent"
	filters: {
		branches: [...string]
		...
	}
}

#ManualEvent: traits.#WorkflowTrigger & {
	$metadata: trigger: "ManualEvent"
	inputs: [string]:   _
}
