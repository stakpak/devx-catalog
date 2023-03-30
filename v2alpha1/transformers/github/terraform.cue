package github

import (
	"guku.io/devx/v1"
	"guku.io/devx/v2alpha1/workflow/tasks"
)

#ApplyTerraform: {
	tasks.#ApplyTerraform

	dir:     _
	show:    _
	version: _
	auth:    _

	spec: {
		name:      string | *"Apply Terraform"
		"runs-on": "ubuntu-latest"
		steps: [
			{
				name: "Checkout"
				uses: "actions/checkout@v3"
			},
			if auth.aws != _|_ {
				{
					name: "Configure AWS credentials"
					uses: "aws-actions/configure-aws-credentials@v1"
					with: {
						if auth.aws.accessKeyId != _|_ {
							if (auth.aws.accessKeyId & string) != _|_ {
								"aws-access-key-id": auth.aws.accessKeyId
							}
							if (auth.aws.accessKeyId & v1.#Secret) != _|_ {
								"aws-access-key-id": "${{ secrets.\(auth.aws.accessKeyId.name) }}"
							}
						}
						if auth.aws.accessKeySecret != _|_ {
							if (auth.aws.accessKeySecret & string) != _|_ {
								"aws-secret-access-key": auth.aws.accessKeySecret
							}
							if (auth.aws.accessKeySecret & v1.#Secret) != _|_ {
								"aws-secret-access-key": "${{ secrets.\(auth.aws.accessKeySecret.name) }}"
							}
						}
						if auth.aws.session != _|_ {
							"role-session-name": auth.aws.session
						}
						if auth.aws.role != _|_ {
							"role-to-assume": auth.aws.role
						}
						"aws-region": auth.aws.region
					}
				}
			},
			{
				name: "Setup Terraform"
				uses: "hashicorp/setup-terraform@v2"
				with: {
					terraform_version: version
					terraform_wrapper: false
				}
			},
			{
				name:                "Terraform Init"
				id:                  "init"
				run:                 "terraform init"
				"working-directory": dir
				shell:               "bash"
			},
			{
				name:                "Terraform Plan"
				id:                  "plan"
				run:                 "terraform plan -input=false -no-color -out tf.plan"
				"working-directory": dir
				shell:               "bash"
			},
			if show {
				{
					name:                "Terraform Show"
					id:                  "show"
					run:                 "terraform show -no-color tf.plan 2>&1 > /tmp/plan.txt"
					"working-directory": dir
					shell:               "bash"
				}
			},
			if show {
				{
					uses: "actions/github-script@v6"
					"if": "github.event_name == 'pull_request'"
					with: {
						"github-token": "${{ inputs.GITHUB_TOKEN }}"
						script: #"""
						const fs = require("fs");
						const plan = fs.readFileSync("/tmp/plan.txt", "utf8");
						const maxGitHubBodyCharacters = 65536;

						function chunkSubstr(str, size) {
						const numChunks = Math.ceil(str.length / size)
						const chunks = new Array(numChunks)
						for (let i = 0, o = 0; i < numChunks; ++i, o += size) {
						    chunks[i] = str.substr(o, size)
						}
						return chunks
						}

						// Split the Terraform plan into chunks if it's too big and can't fit into the GitHub Action
						var plans = chunkSubstr(plan, maxGitHubBodyCharacters); 
						for (let i = 0; i < plans.length; i++) {
						const output = `### ${{ inputs.plan-title }} Part # ${i + 1}
						#### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
						#### Terraform Plan 📖\`${{ steps.plan.outcome }}\`
						<details><summary>Show Plan</summary>
						\`\`\`\n
						${plans[i]}
						\`\`\`
						</details>
						*Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`, Working Directory: \`${{ inputs.working-directory }}\`, Workflow: \`${{ github.workflow }}\`*`;   

						await github.rest.issues.createComment({
						    issue_number: context.issue.number,
						    owner: context.repo.owner,
						    repo: context.repo.repo,
						    body: output
						})
						}
						"""#
					}
				}
			},
		]
		...
	}
}
