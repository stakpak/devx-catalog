package aws

import (
	"encoding/json"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v2alpha1/traits"
	"stakpak.dev/devx/v2alpha1/workflow/tasks"
	schema "stakpak.dev/devx/v1/transformers/terraform"
)

#AddECRRepositoryWorkflow: v1.#Transformer & {
	traits.#Workflow
	$metadata: _
	workflow:  _
	$resources: "\($metadata.id)-ecr": schema.#Terraform & {
		for _, task in workflow.tasks if (task & tasks.#BuildPushECR) != _|_ {
			resource: {
				aws_ecr_repository: "\(task.repository)": {
					name:                 task.repository
					image_tag_mutability: *"MUTABLE" | "IMMUTABLE"
					image_scanning_configuration: scan_on_push: bool | *true
					encryption_configuration: encryption_type:  "AES256"
				}
				aws_ecr_lifecycle_policy: "\(task.repository)": {
					repository: "${aws_ecr_repository.\(task.repository).name}"
					policy:     json.Marshal({
						rules: [
							{
								rulePriority: 1
								description:  "Expire untagged images older than 30 days"
								selection: {
									tagStatus:   "untagged"
									countType:   "sinceImagePushed"
									countUnit:   "days"
									countNumber: 30
								}
								action: type: "expire"
							},
							{
								rulePriority: 2
								description:  "Keep last 30 tagged images"
								selection: {
									tagStatus: "tagged"
									countType: "imageCountMoreThan"
									tagPrefixList: ["v"]
									countNumber: 30
								}
								action: type: "expire"
							},
						]
					})
				}
			}
		}
	}
}

#AddECRRepositoryOCI: v1.#Transformer & {
	traits.#OCIRepository
	$metadata: _
	oci:       _
	$resources: "\($metadata.id)-ecr": schema.#Terraform & {
		resource: {
			aws_ecr_repository: "\(oci.name)": {
				name:                 oci.name
				image_tag_mutability: *"MUTABLE" | "IMMUTABLE"
				image_scanning_configuration: scan_on_push: bool | *true
				encryption_configuration: encryption_type:  "AES256"
			}
			aws_ecr_lifecycle_policy: "\(oci.name)": {
				repository: "${aws_ecr_repository.\(oci.name).name}"
				policy:     json.Marshal({
					rules: [
						{
							rulePriority: 1
							description:  "Expire untagged images older than 30 days"
							selection: {
								tagStatus:   "untagged"
								countType:   "sinceImagePushed"
								countUnit:   "days"
								countNumber: 30
							}
							action: type: "expire"
						},
						{
							rulePriority: 2
							description:  "Keep last 30 tagged images"
							selection: {
								tagStatus: "tagged"
								countType: "imageCountMoreThan"
								tagPrefixList: ["v"]
								countNumber: 30
							}
							action: type: "expire"
						},
					]
				})
			}
		}
	}
}
