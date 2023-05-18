package helpers

#ParameterStoreAWSIAMPolicy: {
	prefix!: string
	aws!: {
		region:  string
		account: string
		...
	}
	policy: {
		actions: [
			"ssm:GetParameter",
			"ssm:ListTagsForResource",
			"ssm:DescribeParameters",
		]
		resources: ["arn:aws:ssm:\(aws.region):\(aws.account):parameter/\(prefix)*"]
		...
	}
}

#SecretsManagerAWSIAMPolicy: {
	prefix!: string
	aws!: {
		region:  string
		account: string
		...
	}
	policy: {
		actions: [
			"secretsmanager:GetResourcePolicy",
			"secretsmanager:GetSecretValue",
			"secretsmanager:DescribeSecret",
			"secretsmanager:ListSecretVersionIds",
		]
		resources: [
			"arn:aws:secretsmanager:\(aws.region):\(aws.account):secret:\(prefix)*",
		]
		...
	}
}
