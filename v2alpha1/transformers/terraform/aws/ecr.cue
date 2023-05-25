package aws

import (
	"encoding/json"
	"guku.io/devx/v1"
	"guku.io/devx/v2alpha1/traits"
	"guku.io/devx/v2alpha1/workflow/tasks"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddECRRepository: v1.#Transformer & {
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
