package helpers

#ECRAWSIAMPolicy: {
	aws!: {
		region:  string
		account: string
		...
	}
	policy: {
		actions: [
			"ecr:BatchCheckLayerAvailability",
			"ecr:BatchGetImage",
			"ecr:GetDownloadUrlForLayer",
			"ecr:GetAuthorizationToken",
		]
		resources: ["*"]
		...
	}
}
