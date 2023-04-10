package aws

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

// add an EFS volume
#AddEFSVolume: v1.#Transformer & {
	traits.#Volume
	$metadata: _

	volumes: _

	aws: {
		vpc: {
			name: string
			...
		}
		...
	}

	volumeName: string | *$metadata.id
	$resources: terraform: schema.#Terraform & {
		data: {
			aws_vpc: "\(aws.vpc.name)": tags: Name: aws.vpc.name
			aws_subnets: "\(aws.vpc.name)": {
				filter: [
					{
						name: "vpc-id"
						values: ["${data.aws_vpc.\(aws.vpc.name).id}"]
					},
					{
						name: "mapPublicIpOnLaunch"
						values: ["false"]
					},
				]
			}
		}
		resource: {
			for k, v in volumes {
				if v.persistent != _|_ {
					aws_efs_file_system: "\(k)": {
						creation_token: v.persistent
						tags: Name: v.persistent
						encrypted:        bool | *true
						performance_mode: *"generalPurpose" | "maxIO"
					}
					aws_efs_mount_target: "\(k)": {
						count:          "${length(data.aws_subnets.\(aws.vpc.name).ids)}"
						file_system_id: "${aws_efs_file_system.\(k).id}"
						subnet_id:      "${tolist(data.aws_subnets.\(aws.vpc.name).ids)[count.index]}"
					}
				}
			}
		}
	}
}
