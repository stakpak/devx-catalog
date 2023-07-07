package aws

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
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
			aws_subnet: "\(aws.vpc.name)": {
				count: "${length(data.aws_subnets.\(aws.vpc.name).ids)}"
				id:    "${tolist(data.aws_subnets.\(aws.vpc.name).ids)[count.index]}"
			}
		}
		resource: {
			for _, v in volumes if v.persistent != _|_ {
				aws_security_group: "efs_mount_target_internal_\(v.persistent)": {
					name:   "efs-mount-target-internal-\(v.persistent)"
					vpc_id: "${data.aws_vpc.\(aws.vpc.name).id}"

					ingress: [{
						from_port:   0
						to_port:     0
						protocol:    "-1"
						cidr_blocks: "${data.aws_subnet.\(aws.vpc.name).*.cidr_block}"

						description:      null
						ipv6_cidr_blocks: null
						prefix_list_ids:  null
						self:             null
						security_groups:  null
					}]
				}
				aws_efs_file_system: "\(v.persistent)": {
					creation_token: v.persistent
					tags: Name: v.persistent
					encrypted:        bool | *true
					performance_mode: *"generalPurpose" | "maxIO"
				}
				aws_efs_mount_target: "\(v.persistent)": {
					count:          "${length(data.aws_subnets.\(aws.vpc.name).ids)}"
					file_system_id: "${aws_efs_file_system.\(v.persistent).id}"
					subnet_id:      "${tolist(data.aws_subnets.\(aws.vpc.name).ids)[count.index]}"
					security_groups: [
						"${aws_security_group.efs_mount_target_internal_\(v.persistent).id}",
					]
				}
				// aws_efs_access_point: "\(v.persistent)": {
				//  file_system_id: "${aws_efs_file_system.\(v.persistent).id}"
				// }
			}
		}
	}
}
