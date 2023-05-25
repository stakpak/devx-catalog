package longhorn

import (
	"guku.io/devx/k8s"
	"k8s.io/api/core/v1"
)

#KubeVersion: [=~"^1\\.4\\."]: minor: >=21
#Values: [=~"^1\\.4\\."]: {
	global: {
		cattle: {
			systemDefaultRegistry: string | *""
			windowsCluster: {
				enabled:     bool | *false
				tolerations: [...v1.#Toleration] | *[{
					key:      string | *"cattle.io/os"
					value:    string | *"linux"
					effect:   string | *"NoSchedule"
					operator: string | *"Equal"
				}]
				nodeSelector: {
					"kubernetes.io/os": "linux"
				}
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
				tag:        string | *"v1.4.2"
			}
			manager: {
				repository: string | *"longhornio/longhorn-manager"
				tag:        string | *"v1.4.2"
			}
			ui: {
				repository: string | *"longhornio/longhorn-ui"
				tag:        string | *"v1.4.2"
			}
			instanceManager: {
				repository: string | *"longhornio/longhorn-instance-manager"
				tag:        string | *"v1.4.2"
			}
			shareManager: {
				repository: string | *"longhornio/longhorn-share-manager"
				tag:        string | *"v1.4.2"
			}
			backingImageManager: {
				repository: string | *"longhornio/backing-image-manager"
				tag:        string | *"v1.4.2"
			}
			supportBundleKit: {
				repository: string | *"longhornio/support-bundle-kit"
				tag:        string | *"v0.0.24"
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
				tag:        string | *"v1.3.0"
			}
			snapshotter: {
				repository: string | *"longhornio/csi-snapshotter"
				tag:        string | *"v5.0.1"
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
		defaultClass:             bool | *true
		defaultFsType:            "ext4"
		defaultMkfsParams:        ""
		defaultClassReplicaCount: int | *3
		defaultDataLocality:      "best-effort" | *"disabled"
		// defaultReplicaAutoBalance: "disabled" | "least-effort" | "best-effort" | *"ignored"
		reclaimPolicy: "Delete"
		migratable:    bool | *false
		recurringJobSelector: {
			enable: bool | *false
			jobList: []
		}
		backingImage: {
			enable:               bool | *false
			name:                 null
			dataSourceType:       null
			dataSourceParameters: null
			expectedChecksum:     null
		}
		defaultNodeSelector: {
			enable: bool | *false
			selector: []
		}
		removeSnapshotsDuringFilesystemTrim: "disabled" | "enabled" | *"ignored"
	}
	csi: {
		kubeletRootDir:          null
		attacherReplicaCount:    null
		provisionerReplicaCount: null
		resizerReplicaCount:     null
		snapshotterReplicaCount: null
	}
	defaultSettings: {
		backupTarget:                                             null
		backupTargetCredentialSecret:                             null
		allowRecurringJobWhileVolumeDetached:                     null
		createDefaultDiskLabeledNodes:                            null
		defaultDataPath:                                          null
		defaultDataLocality:                                      null
		replicaSoftAntiAffinity:                                  null
		replicaAutoBalance:                                       null
		storageOverProvisioningPercentage:                        null
		storageMinimalAvailablePercentage:                        null
		upgradeChecker:                                           null
		defaultReplicaCount:                                      null
		defaultLonghornStaticStorageClass:                        null
		backupstorePollInterval:                                  null
		failedBackupTTL:                                          null
		restoreVolumeRecurringJobs:                               null
		recurringSuccessfulJobsHistoryLimit:                      null
		recurringFailedJobsHistoryLimit:                          null
		supportBundleFailedHistoryLimit:                          null
		taintToleration:                                          null
		systemManagedComponentsNodeSelector:                      null
		priorityClass:                                            null
		autoSalvage:                                              null
		autoDeletePodWhenVolumeDetachedUnexpectedly:              null
		disableSchedulingOnCordonedNode:                          null
		replicaZoneSoftAntiAffinity:                              null
		nodeDownPodDeletionPolicy:                                null
		allowNodeDrainWithLastHealthyReplica:                     null
		nodeDrainPolicy:                                          null
		mkfsExt4Parameters:                                       null
		disableReplicaRebuild:                                    null
		replicaReplenishmentWaitInterval:                         null
		concurrentReplicaRebuildPerNodeLimit:                     null
		concurrentVolumeBackupRestorePerNodeLimit:                null
		disableRevisionCounter:                                   null
		systemManagedPodsImagePullPolicy:                         null
		allowVolumeCreationWithDegradedAvailability:              null
		autoCleanupSystemGeneratedSnapshot:                       null
		concurrentAutomaticEngineUpgradePerNodeLimit:             null
		backingImageCleanupWaitInterval:                          null
		backingImageRecoveryWaitInterval:                         null
		guaranteedEngineManagerCPU:                               null
		guaranteedReplicaManagerCPU:                              null
		kubernetesClusterAutoscalerEnabled:                       null
		orphanAutoDeletion:                                       null
		storageNetwork:                                           null
		deletingConfirmationFlag:                                 null
		engineReplicaTimeout:                                     null
		snapshotDataIntegrity:                                    null
		snapshotDataIntegrityImmediateCheckAfterSnapshotCreation: null
		snapshotDataIntegrityCronjob:                             null
		removeSnapshotsDuringFilesystemTrim:                      null
		fastReplicaRebuildEnabled:                                null
		replicaFileSyncHttpClientTimeout:                         null
	}
	privateRegistry: {
		createSecret:   null
		registryUrl:    null
		registryUser:   null
		registryPasswd: null
		registrySecret: null
	}

	longhornManager: {
		log: {
			format: "json" | *"plain"
		}
		priorityClass: null
		tolerations: [...v1.#Toleration]
		nodeSelector:       k8s.#Labels
		serviceAnnotations: k8s.#Annotations
	}

	longhornDriver: {
		priorityClass: null
		tolerations: [...v1.#Toleration]
		nodeSelector: k8s.#Labels
	}

	longhornUI: {
		replicas:      int | *2
		priorityClass: null
		tolerations: [...v1.#Toleration]
		nodeSelector: k8s.#Labels
	}

	longhornAdmissionWebhook: {
		replicas:      int | *2
		priorityClass: null
		tolerations: [...v1.#Toleration]
		nodeSelector: k8s.#Labels
	}

	longhornRecoveryBackend: {
		replicas:      int | *2
		priorityClass: null
		tolerations: [...v1.#Toleration]
		nodeSelector: k8s.#Labels
	}

	ingress: {
		enabled:          bool | *false
		ingressClassName: null
		host:             "sslip.io"
		tls:              bool | *false
		secureBackends:   bool | *false
		tlsSecret:        string | *"longhorn.local-tls"
		path:             string | *"/"
		annotations:      k8s.#Annotations | *null
		secrets:          [...{
			name:        string
			key:         string
			certificate: string
		}] | *null
	}

	enablePSP: bool | *false

	namespaceOverride: string | *""

	annotations: k8s.#Annotations

	serviceAccount: {
		annotations: k8s.#Annotations
	}
}
