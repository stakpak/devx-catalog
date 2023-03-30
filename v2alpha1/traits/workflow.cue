package traits

import "guku.io/devx/v1"

// an automation workflow
#Workflow: v1.#Trait & {
	$metadata: traits: Workflow: null
	workflow: {
		name: string | *$metadata.id
		triggers: [ID=string]: #WorkflowTrigger & {
			id: ID
		}
		tasks: [ID=string]: #WorkflowTask & {
			id: ID
		}
	}
}

#WorkflowTask: {
	$metadata: task: string | *""
	id: string
	dependencies: [...{id: string, ...}]
	...
}

#WorkflowTrigger: {
	$metadata: trigger: string | *""
	id: string
	...
}
