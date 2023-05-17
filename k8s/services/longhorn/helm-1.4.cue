package longhorn

#KubeVersion: [=~"^1\\.4\\."]: minor: >=20
#Values: [=~"^1\\.4\\."]: {
	global: {
		cattle: {
			systemDefaultRegistry: string | *"k"
			windowsCluster: {
				enabled: bool | *false
				tolerations: [
					{
						key:      string | *"cattle.io/os"
						linux:    string | *"linux"
						effect:   string | *"NoSchedule"
						operator: string | *"Equal"
					},
				]
				defaultSetting: {
					taintToleration:                     "cattle.io/os=linux:NoSchedule"
					systemManagedComponentsNodeSelector: "kubernetes.io/os:linux"
				}
			}
		}
	}
	image: {
		longhorn: {
			engine: {
				repository: string | *"longhornio/longhorn-engine"
				tag:        string | *"v1.4.0"
			}
			manager: {
				repository: string | *"longhornio/longhorn-manager"
				tag:        string | *"v1.4.0"
			}
			ui: {
				repository: string | *"longhornio/longhorn-ui"
				tag:        string | *"v1.4.0"
			}
			instanceManager: {
				repository: string | *"longhornio/longhorn-instance-manager"
				tag:        string | *"v1.4.0"
			}
			shareManager: {
				repository: string | *"longhornio/longhorn-share-manager"
				tag:        string | *"v1.4.0"
			}
			backingImageManager: {
				repository: string | *"longhornio/backing-image-manager"
				tag:        string | *"v1.4.0"
			}
			supportBundleKit: {
				repository: string | *"longhornio/support-bundle-kit"
				tag:        string | *"v0.0.17"
			}
		}
		csi: {
			attacher: {
				repository: string | *"longhornio/csi-attacher"
				tag:        string | *"v3.4.0"
			}
			provisioner: {
				repository: string | *"longhornio/csi-provisioner"
				tag:        string | *"v2.1.2"
			}
			nodeDriverRegistrar: {
				repository: string | *"longhornio/csi-node-driver-registrar"
				tag:        string | *"v2.5.0"
			}
			resizer: {
				repository: string | *"longhornio/csi-resizer"
				tag:        string | *"v5.0.1"
			}
			snapshotter: {
				repository: string | *"longhornio/csi-snapshotter"
				tag:        string | *"v2.1.1"
			}
			livenessProbe: {
				repository: string | *"longhornio/livenessprobe"
				tag:        string | *"v2.8.0"
			}
		}
		pullPolicy: string | *"IfNotPresent"
	}
	service: {
		ui: {
			type:     string | *"ClusterIP"
			nodePort: string | *null
		}
		manager: {
			type:                     string | *"ClusterIP"
			nodePort:                 string | *""
			loadBalancerIP:           string | *""
			loadBalancerSourceRanges: string | *""
		}
	}
	persistence: {
		defaultClass:              bool | *true
		defaultFsType:             "ext4"
		defaultMkfsParams:         ""
		defaultClassReplicaCount:  int | *3
		defaultDataLocality:       "best-effort" | *"disabled"
		defaultReplicaAutoBalance: "disabled" | "least-effort" | "best-effort" | *"ignored"
		reclaimPolicy:             "Delete"
		migratable:                bool | *false
		recurringJobSelector: {
			enable: bool | *false
			jobList: []
		}
		backingImage: {
			enable:               bool | *false
			name:                 "~"
			dataSourceType:       "~"
			dataSourceParameters: "~"
			expectedChecksum:     "~"
		}
		defaultNodeSelector: {
			enable: bool | *false
			selector: []
		}
		removeSnapshotsDuringFilesystemTrim: "disabled" | "enabled" | *"ignored"
	}
	csi: {
		kubeletRootDir:          "~"
		attacherReplicaCount:    "~"
		provisionerReplicaCount: "~"
		resizerReplicaCount:     "~"
		snapshotterReplicaCount: "~"
	}
	defaultSettings: {
		backupTarget:                                             "~"
		backupTargetCredentialSecret:                             "~"
		allowRecurringJobWhileVolumeDetached:                     "~"
		createDefaultDiskLabeledNodes:                            "~"
		defaultDataPath:                                          "~"
		defaultDataLocality:                                      "~"
		replicaSoftAntiAffinity:                                  "~"
		replicaAutoBalance:                                       "~"
		storageOverProvisioningPercentage:                        "~"
		storageMinimalAvailablePercentage:                        "~"
		upgradeChecker:                                           "~"
		defaultReplicaCount:                                      "~"
		defaultLonghornStaticStorageClass:                        "~"
		backupstorePollInterval:                                  "~"
		failedBackupTTL:                                          "~"
		restoreVolumeRecurringJobs:                               "~"
		recurringSuccessfulJobsHistoryLimit:                      "~"
		recurringFailedJobsHistoryLimit:                          "~"
		supportBundleFailedHistoryLimit:                          "~"
		taintToleration:                                          "~"
		systemManagedComponentsNodeSelector:                      "~"
		priorityClass:                                            "~"
		autoSalvage:                                              "~"
		autoDeletePodWhenVolumeDetachedUnexpectedly:              "~"
		disableSchedulingOnCordonedNode:                          "~"
		replicaZoneSoftAntiAffinity:                              "~"
		nodeDownPodDeletionPolicy:                                "~"
		allowNodeDrainWithLastHealthyReplica:                     "~"
		mkfsExt4Parameters:                                       "~"
		disableReplicaRebuild:                                    "~"
		replicaReplenishmentWaitInterval:                         "~"
		concurrentReplicaRebuildPerNodeLimit:                     "~"
		concurrentVolumeBackupRestorePerNodeLimit:                "~"
		disableRevisionCounter:                                   "~"
		systemManagedPodsImagePullPolicy:                         "~"
		allowVolumeCreationWithDegradedAvailability:              "~"
		autoCleanupSystemGeneratedSnapshot:                       "~"
		concurrentAutomaticEngineUpgradePerNodeLimit:             "~"
		backingImageCleanupWaitInterval:                          "~"
		backingImageRecoveryWaitInterval:                         "~"
		guaranteedEngineManagerCPU:                               "~"
		guaranteedReplicaManagerCPU:                              "~"
		kubernetesClusterAutoscalerEnabled:                       "~"
		orphanAutoDeletion:                                       "~"
		storageNetwork:                                           "~"
		deletingConfirmationFlag:                                 "~"
		engineReplicaTimeout:                                     "~"
		snapshotDataIntegrity:                                    "~"
		snapshotDataIntegrityImmediateCheckAfterSnapshotCreation: "~"
		snapshotDataIntegrityCronjob:                             "~"
		removeSnapshotsDuringFilesystemTrim:                      "~"
		fastReplicaRebuildEnabled:                                "~"
		replicaFileSyncHttpClientTimeout:                         "~"
	}
	privateRegistry: {
		createSecret:   "~"
		registryUrl:    "~"
		registryUser:   "~"
		registryPasswd: "~"
		registrySecret: "~"
	}

	longhornManager: {
		log: {
			format: "json" | *"plain"
		}
		priorityClass: "~"
		tolerations:   [{
			key:      string
			operator: string
			value:    string
			effect:   string
		}] | *[]
		nodeSelector:       {string: string} | *{}
		serviceAnnotations: {string: string} | *{}
	}

	longhornUI: {
		replicas:      int | *2
		priorityClass: "~"
		tolerations:   [{
			key:      string
			operator: string
			value:    string
			effect:   string
		}] | *[]
		nodeSelector: {string: string} | *{}
	}

	longhornAdmissionWebhook: {
		replicas:      int | *2
		priorityClass: "~"
		tolerations:   [{
			key:      string
			operator: string
			value:    string
			effect:   string
		}] | *[]
		nodeSelector: {string: string} | *{}
	}

	longhornRecoveryBackend: {
		replicas:      int | *2
		priorityClass: "~"
		tolerations:   [{
			key:      string
			operator: string
			value:    string
			effect:   string
		}] | *[]
		nodeSelector: {string: string} | *{}
	}

	ingress: {
		enabled:          bool | *false
		ingressClassName: "~"
		host:             "sslip.io"
		tls:              bool | *false
		secureBackends:   bool | *false
		tlsSecret:        string | *"longhorn.local-tls"
		path:             string | *"/"
		annotations:      {string: string} | *{}
		secrets:          [{
			name:        string
			key:         string
			certificate: string
		}] | *[]
	}

	enablePSP: bool | *false

	namespaceOverride: string | *""

	annotations: {string: string} | *{}

	serviceAccount: {
		annotations: {string: string} | *{}
	}
}
