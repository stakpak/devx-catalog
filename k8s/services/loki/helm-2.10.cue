package loki

#KubeVersion: [=~"^2\\.10\\."]: minor: >=21
#Values: [=~"^2\\.10\\."]: {

    loki: {
        env: [
            {
                name: "AWS_ACCESS_KEY_ID"
                valueFrom: {
                    secretKeyRef: {
                        name: *"iam-loki-s3" | string
                        key:  *"AWS_ACCESS_KEY_ID" | string
                    }
                }
            },
            {
                name: "AWS_SECRET_ACCESS_KEY"
                valueFrom: {
                    secretKeyRef: {
                        name: *"iam-loki-s3" | string
                        key:  *"AWS_SECRET_ACCESS_KEY" | string
                    }
                }
            }
        ]
        ...
    }

    promtail: {
        enabled: *true | bool
        config: {
            clients: [{
                url: *"http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push" | string
            }]
        }
    }

}
