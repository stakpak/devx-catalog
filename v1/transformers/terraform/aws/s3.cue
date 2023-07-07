package aws

import (
	"encoding/json"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
)

// Add S3 bucket
#AddS3Bucket: v1.#Transformer & {
	traits.#S3CompatibleBucket

	$metadata: _
	s3:        _
	$resources: terraform: schema.#Terraform & {
		resource: {
			aws_s3_bucket: "\($metadata.id)": bucket: s3.fullBucketName
			if s3.objectLocking {
				aws_s3_bucket_object_lock_configuration: "\($metadata.id)": bucket: "${aws_s3_bucket.\($metadata.id).bucket}"
			}
			if s3.versioning {
				aws_s3_bucket_versioning: "\($metadata.id)": {
					bucket: "${aws_s3_bucket.\($metadata.id).bucket}"
					versioning_configuration: status: "Enabled"
				}
			}
			if s3.policy != _|_ {
				aws_s3_bucket_policy: "\($metadata.id)": {
					bucket: "${aws_s3_bucket.\($metadata.id).bucket}"
					policy: json.Marshal(s3.policy)
				}
			}

		}
	}
}
