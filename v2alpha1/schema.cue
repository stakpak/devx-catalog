package v2alpha1

import (
	"guku.io/devx/v1"
)

#Environments: {
	[Environment=string]: #StackBuilder & {
		environment: Environment
	}
}

#StackBuilder: {
	$metadata: builder: string | *environment

	taskfile?: #Taskfile

	environment: string
	flows: [string]: v1.#Flow
	drivers: {
		[Driver=string]: output: dir: [...string] | *["build", environment, Driver]

		terraform: output: file:  string | *"generated.tf.json"
		gitlab: output: file:     string | *".gitlab-ci.yml"
		compose: output: file:    string | *"docker-compose.yml"
		github: output: file:     string | *""
		kubernetes: output: file: string | *""
	}

	config?: [string]:        _
	components?: [Id=string]: v1.#Component & {
		$metadata: id: Id
	}
}
