package traits

import (
	"net"
	"guku.io/devx/v1"
	"guku.io/devx/v1/resources/aws"
)

// a virtual private cloud network
#VPC: v1.#Trait & {
	$metadata: traits: VPC: null
	vpc: {
		name: string
		cidr: string & net.IPCIDR
		subnets: {
			private: [... string & net.IPCIDR]
			public: [... string & net.IPCIDR]
		}
	}
}

// an AWS ECS cluster
#ECS: v1.#Trait & {
	$metadata: traits: ECS: null
	ecs: {
		name: string
		logging: {
			enabled:         bool | *true
			retentionInDays: uint | *7
		}
		capacityProviders: {
			[string]: {
				enabled: bool | *false
				defaultStrategy: weight?: uint & <=100
			}
			fargate: {}
			fargateSpot: {}
		}
		environment?: string
	}
}

// an s3 compatible bucket
#S3CompatibleBucket: v1.#Trait & {
	$metadata: traits: S3Bucket: null
	s3: {
		prefix:         string | *""
		name:           string
		fullBucketName: "\(prefix)\(name)"

		objectLocking: bool | *false
		versioning:    bool | *true

		policy?:       aws.#IAMPolicy
		url?:          string
		accessKey?:    string | v1.#Secret
		accessSecret?: string | v1.#Secret
	}
}

// a dynamodb table
#DynamoDBTable: v1.#Trait & {
	$metadata: traits: DynamoDBTable: null
	table: {
		name:    string | *$metadata.id
		billing: "PROVISIONED" | "PAY_PER_REQUEST"

		capacity?: {
			read:  uint
			write: uint
		}

		if billing == "PROVISIONED" {
			capacity: {
				read:  uint
				write: uint
			}
		}

		key: {
			partition: {
				name: string
				type: "S" | "N" | "B"
			}
			sort?: {
				name: string
				type: "S" | "N" | "B"
			}
		}

		stream?: view: "KEYS_ONLY" | "NEW_IMAGE" | "OLD_IMAGE" | "NEW_AND_OLD_IMAGES"
	}
}
