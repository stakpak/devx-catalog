package aws

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
)

#AddDynamoDBTable: v1.#Transformer & {
	traits.#DynamoDBTable
	$metadata: _
	table:     _
	$resources: "\($metadata.id)-dynamo": schema.#Terraform & {
		resource: aws_dynamodb_table: "\($metadata.id)": {
			name:         table.name
			billing_mode: table.billing

			hash_key: table.key.partition.name
			if table.key.sort != _|_ {
				range_key: table.key.sort.name
			}

			attribute: [
				{
					name: table.key.partition.name
					type: table.key.partition.type
				},
				if table.key.sort != _|_ {
					{
						name: table.key.sort.name
						type: table.key.sort.type
					}
				},
			]

			if table.stream != _|_ {
				stream_enabled:   true
				stream_view_type: table.stream.view
			}
		}
	}
}
