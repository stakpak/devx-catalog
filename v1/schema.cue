package v1

import (
	"list"
	"encoding/json"
)

#Secret: {
	$metadata: secret: null
	name:      string
	key:       string | *name
	version?:  string
	property?: string
}

#Trait: {
	#Component
	$metadata: traits: [string]: _ | *null
	...
}

#Component: {
	$metadata: {
		id: string
		labels: [string]: string
		transformed?: bool
	}
	#Trait
}

#Stack: {
	$metadata: *"Stack" | {
		stack: string
	}
	components: [Id=string]: #Component & {
		$metadata: id: Id
	}
}

#Transformer: {
	#Component
	$metadata: transformed: true
	$resources: [string]: {
		$metadata: labels: [string]: string
		$metadata: labels: driver:   string
		$metadata: labels: type:     string
		...
	}
}

#StackBuilder: {
	[string]: {
		drivers?: ["terraform" | "kubernetes" | "gitlab" | "github" | "compose"]: output: string

		// we might not use this at all in V1
		additionalComponents?: [Id=string]: #Component & {
			$metadata: id: Id
		}

		preflows: [...#Flow]
		mainflows: [...#Flow]
		postflows: [...#Flow]

		flows: list.Concat([
			preflows,
			mainflows,
			postflows,
		])
	}
}

#Flow: {
	match: {
		traits: [string]: _
		labels: [string]: string
	}
	exclude: {
		traits: [string]: _
		labels: [string]: string
	}

	pipeline: [...#Transformer]

	// include all transformer traits by default in match
	for t in pipeline {
		match: traits: t.$metadata.traits
	}
}

#TestCase: {
	$metadata: test: string

	description: string | ""

	transformer: #Transformer
	input:       #Component
	output:      input & transformer

	expect: output
	assert: [string]: true
}

#GlobalPolicy: {
	$metadata: policy: name

	name: string
	environments: [...string]
	enforced: bool | *false
	disabled: bool | *false
	pipeline: [...#GlobalPolicyPipelineStage]
	pipelineJSON: json.Marshal(pipeline)
}

#GlobalPolicyPipelineStage: [string]: _
