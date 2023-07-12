package triggers

import (
	"stakpak.dev/devx/v2alpha1/traits"
)

#Filters: {
	branches?: [...string]
	tags?: [...string]
	paths?: [...string]
	branchesIgnore?: [...string]
	tagsIgnore?: [...string]
	pathsIgnore?: [...string]
}

#PushEvent: traits.#WorkflowTrigger & {
	$metadata: trigger: "PushEvent"
	filters: #Filters
}

#PullRequestEvent: traits.#WorkflowTrigger & {
	$metadata: trigger: "PullRequestEvent"
	filters: #Filters
}

#ManualEvent: traits.#WorkflowTrigger & {
	$metadata: trigger: "ManualEvent"
	inputs: [string]:   _
}
