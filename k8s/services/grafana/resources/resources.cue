package resources

#GrafanaDataSource: {
        "datasources.yaml": {
            apiVersion: 1
            datasources: [...{
                name:      string
                type:      string
                url:       string
                access:    "proxy"
                isDefault: bool | *false
            }]
        }
}