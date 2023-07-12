package github

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v2alpha1/traits"
	"stakpak.dev/devx/v2alpha1/workflow/tasks"
	"stakpak.dev/devx/v2alpha1/workflow/triggers"
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
		on: {
			for _, trigger in workflow.triggers {
				if (triggers.#PushEvent & trigger) != _|_ {
					push: {
						if trigger.filters.branches != _|_ {
							branches: trigger.filters.branches
						}
						if trigger.filters.tags != _|_ {
							tags: trigger.filters.tags
						}
						if trigger.filters.paths != _|_ {
							paths: trigger.filters.paths
						}
						if trigger.filters.branchesIgnore != _|_ {
							"branches-ignore": trigger.filters.branchesIgnore
						}
						if trigger.filters.tagsIgnore != _|_ {
							"tags-ignore": trigger.filters.tagsIgnore
						}
						if trigger.filters.pathsIgnore != _|_ {
							"paths-ignore": trigger.filters.pathsIgnore
						}
					}
				}
				if (triggers.#PullRequestEvent & trigger) != _|_ {
					pull_request: {
						if trigger.filters.branches != _|_ {
							branches: trigger.filters.branches
						}
						if trigger.filters.tags != _|_ {
							tags: trigger.filters.tags
						}
						if trigger.filters.paths != _|_ {
							paths: trigger.filters.paths
						}
						if trigger.filters.branchesIgnore != _|_ {
							"branches-ignore": trigger.filters.branchesIgnore
						}
						if trigger.filters.tagsIgnore != _|_ {
							"tags-ignore": trigger.filters.tagsIgnore
						}
						if trigger.filters.pathsIgnore != _|_ {
							"paths-ignore": trigger.filters.pathsIgnore
						}
					}
				}
				if trigger.$metadata.trigger == "ManualEvent" {
					workflow_dispatch: {
						inputs: (triggers.#ManualEvent & trigger).inputs
						...
					}
				}
			}
		}
		jobs: {
			for name, task in workflow.tasks {
				if task.$metadata.task == "BuildPushECR" {
					"\(name)": (#BuildPushECR & task).spec
					"\(name)": needs: [ for t in task.dependencies {t.id}]
				}
				if task.$metadata.task == "Terraform" {
					"\(name)": (#Terraform & task).spec
					"\(name)": needs: [ for t in task.dependencies {t.id}]
				}
				if task.$metadata.task == "RawTask" {
					"\(name)": (tasks.#RawTask & task).spec
					"\(name)": needs: [ for t in task.dependencies {t.id}]
				}
			}
		}
	}
}
