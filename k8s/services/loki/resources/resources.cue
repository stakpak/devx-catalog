package resources

#LokiStorageConfig: {
        schema_config: {
            configs: [{
                from:         *"2021-05-12" | string
                store:        *"boltdb-shipper" | string
                object_store: *"s3" | string
                schema:       *"v11" | string
                index: {
                    prefix: *"loki_index_" | string
                    period: *"24h" | string
                }
            }]
        }

        storage_config: {
            aws: {
                s3:               *"s3://us-east-1/observtest" | string
                s3forcepathstyle: *true | bool
                bucketnames:      *"observtest" | string
                region:           *"us-east-1" | string
                insecure:         *false | bool
                sse_encryption:   *false | bool
            }
            boltdb_shipper: {
                shared_store: *"s3" | string
                cache_ttl:    *"24h" | string
            }
        }
    }

#Promtail: {
    enabled: *true | bool
    config: {
        clients: [{
            url: *"http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push" | string
        }]
    }
}