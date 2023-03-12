package github

import (
	"strings"
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
		on: push: branches: ["main"]
		permissions: contents: "read"

		jobs: {
			for name, task in workflow.tasks {
				if task.$metadata.task == "BuildPushECR" {
					"\(name)": (#BuildPushECR & task).spec
				}
			}
		}
	}
}

#BuildPushECR: {
	tasks.#BuildPushECR
	image:   _
	tags:    _
	context: _
	dir:     _
	aws:     _
	spec: {
		name:      string | *"Build & Push \(image)"
		"runs-on": "ubuntu-latest"
		steps: [
			{
				name: "Checkout"
				uses: "actions/checkout@v3"
			},
			{
				name: "Set up Docker Buildx"
				uses: "docker/setup-buildx-action@v2"
			},
			{
				name: "Configure AWS credentials"
				uses: "aws-actions/configure-aws-credentials@v1"
				with: {
					if aws.accessKeyId != _|_ {
						if (aws.accessKeyId & string) != _|_ {
							"aws-access-key-id": aws.accessKeyId
						}
						if (aws.accessKeyId & v1.#Secret) != _|_ {
							"aws-access-key-id": "${{ secrets.\(aws.accessKeyId.name) }}"
						}
					}
					if aws.accessKeySecret != _|_ {
						if (aws.accessKeySecret & string) != _|_ {
							"aws-secret-access-key": aws.accessKeySecret
						}
						if (aws.accessKeySecret & v1.#Secret) != _|_ {
							"aws-secret-access-key": "${{ secrets.\(aws.accessKeySecret.name) }}"
						}
					}
					if aws.session != _|_ {
						"role-session-name": aws.session
					}
					if aws.role != _|_ {
						"role-to-assume": aws.role
					}
					"aws-region": aws.region
				}
			},
			{
				name: "Login to Amazon ECR"
				uses: "aws-actions/amazon-ecr-login@v1"
				if aws.public {
					with: "registry-type": "public"
				}
			},
			{
				name:                "Build and push"
				uses:                "docker/build-push-action@v4"
				"working-directory": dir
				with: {
					context:   "."
					platforms: "linux/amd64"
					push:      "true"
					"tags":    strings.Join(
							[
								for tag in tags {"\(image):\(tag)"},
							],
							"\n",
							)
				}
			},
		]
		...
	}
}
