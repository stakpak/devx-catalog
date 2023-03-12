package traits

import "guku.io/devx/v1"

// an automation workflow
#Workflow: v1.#Trait & {
	$metadata: traits: Workflow: null
	workflow: {
		name: string | *$metadata.id
		tasks: [ID=string]: #WorkflowTask & {
			id: ID
		}
	}
}

#WorkflowTask: {
	$metadata: task: string | *""
	id: string
	dependencies: [string]: _
	...
}
