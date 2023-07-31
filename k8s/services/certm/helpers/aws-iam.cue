package helpers

#Route53AWSIAMPolicies: {
	policies: {
		"get-route53-change": {
			actions: ["route53:GetChange"]
			resources: ["arn:aws:route53:::change/*"]
		}
		"update-route53-records": {
			actions: [
				"route53:ChangeResourceRecordSets",
				"route53:ListResourceRecordSets",
			]
			resources: ["arn:aws:route53:::hostedzone/*"]
		}
		"list-route53-zones": {
			actions: "route53:ListHostedZonesByName"
			resources: ["*"]
		}
	}
}
