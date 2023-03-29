package github

import (
	"guku.io/devx/v1"
	"guku.io/devx/v2alpha1/traits"
	"guku.io/devx/v2alpha1/workflow/tasks"
)

#PipelineResource: {
	#GitHubCISpec
	$metadata: labels: {
		driver: "github"
		type:   ""
	}
}

#AddWorkflow: v1.#Transformer & {
	traits.#Workflow
	$metadata: _
	workflow:  _

	$resources: "\($metadata.id)": #PipelineResource & {
		name: workflow.name
		jobs: {
			for name, task in workflow.tasks {
				if task.$metadata.task == "BuildPushECR" {
					"\(name)": (#BuildPushECR & task).spec
				}
				if task.$metadata.task == "RawTask" {
					"\(name)": (tasks.#RawTask & task).spec
				}
			}
		}
	}
}
