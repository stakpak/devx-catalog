package github

import "strings"

#BuildPushECR: {
	image: string
	tags: [...string]
	context: string | *"."
	dir:     string | *"."
	aws: {
		insecure:         bool | *false
		region:           string
		public:           bool | *false
		role?:            string
		session?:         string
		accessKeyId?:     string
		accessKeySecret?: string

		if accessKeyId != _|_ && !insecure {
			"_insecure access key id, use github secrets or set insecure to true": strings.Contains(accessKeyId, "secrets.") & true
		}
		if accessKeySecret != _|_ && !insecure {
			"_insecure access key secret, use github secrets or set insecure to true": strings.Contains(accessKeySecret, "secrets.") & true
		}
	}

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
						"aws-access-key-id": aws.accessKeyId
					}
					if aws.accessKeySecret != _|_ {
						"aws-secret-access-key": aws.accessKeySecret
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
