package longhorn

import (
	"stakpak.dev/devx/k8s"
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
			name:                 string | *null
			dataSourceType:       string | *null
			dataSourceParameters: string | *null
			expectedChecksum:     string | *null
		}
		defaultNodeSelector: {
			enable: bool | *false
			selector: []
		}
		removeSnapshotsDuringFilesystemTrim: "disabled" | "enabled" | *"ignored"
	}
	csi: {
		kubeletRootDir:          string | *null
		attacherReplicaCount:    string | *null
		provisionerReplicaCount: string | *null
		resizerReplicaCount:     string | *null
		snapshotterReplicaCount: string | *null
	}
	defaultSettings: {
		backupTarget:                                             string | *null
		backupTargetCredentialSecret:                             string | *null
		allowRecurringJobWhileVolumeDetached:                     string | *null
		createDefaultDiskLabeledNodes:                            string | *null
		defaultDataPath:                                          string | *null
		defaultDataLocality:                                      string | *null
		replicaSoftAntiAffinity:                                  string | *null
		replicaAutoBalance:                                       string | *null
		storageOverProvisioningPercentage:                        string | *null
		storageMinimalAvailablePercentage:                        string | *null
		upgradeChecker:                                           string | *null
		defaultReplicaCount:                                      string | *null
		defaultLonghornStaticStorageClass:                        string | *null
		backupstorePollInterval:                                  string | *null
		failedBackupTTL:                                          string | *null
		restoreVolumeRecurringJobs:                               string | *null
		recurringSuccessfulJobsHistoryLimit:                      string | *null
		recurringFailedJobsHistoryLimit:                          string | *null
		supportBundleFailedHistoryLimit:                          string | *null
		taintToleration:                                          string | *null
		systemManagedComponentsNodeSelector:                      string | *null
		priorityClass:                                            string | *null
		autoSalvage:                                              string | *null
		autoDeletePodWhenVolumeDetachedUnexpectedly:              string | *null
		disableSchedulingOnCordonedNode:                          string | *null
		replicaZoneSoftAntiAffinity:                              string | *null
		nodeDownPodDeletionPolicy:                                string | *null
		allowNodeDrainWithLastHealthyReplica:                     string | *null
		nodeDrainPolicy:                                          string | *null
		mkfsExt4Parameters:                                       string | *null
		disableReplicaRebuild:                                    string | *null
		replicaReplenishmentWaitInterval:                         string | *null
		concurrentReplicaRebuildPerNodeLimit:                     string | *null
		concurrentVolumeBackupRestorePerNodeLimit:                string | *null
		disableRevisionCounter:                                   string | *null
		systemManagedPodsImagePullPolicy:                         string | *null
		allowVolumeCreationWithDegradedAvailability:              string | *null
		autoCleanupSystemGeneratedSnapshot:                       string | *null
		concurrentAutomaticEngineUpgradePerNodeLimit:             string | *null
		backingImageCleanupWaitInterval:                          string | *null
		backingImageRecoveryWaitInterval:                         string | *null
		guaranteedEngineManagerCPU:                               string | *null
		guaranteedReplicaManagerCPU:                              string | *null
		kubernetesClusterAutoscalerEnabled:                       string | *null
		orphanAutoDeletion:                                       string | *null
		storageNetwork:                                           string | *null
		deletingConfirmationFlag:                                 string | *null
		engineReplicaTimeout:                                     string | *null
		snapshotDataIntegrity:                                    string | *null
		snapshotDataIntegrityImmediateCheckAfterSnapshotCreation: string | *null
		snapshotDataIntegrityCronjob:                             string | *null
		removeSnapshotsDuringFilesystemTrim:                      string | *null
		fastReplicaRebuildEnabled:                                string | *null
		replicaFileSyncHttpClientTimeout:                         string | *null
	}
	privateRegistry: {
		createSecret:   string | *null
		registryUrl:    string | *null
		registryUser:   string | *null
		registryPasswd: string | *null
		registrySecret: string | *null
	}

	longhornManager: {
		log: {
			format: "json" | *"plain"
		}
		priorityClass: string | *null
		tolerations: [...v1.#Toleration]
		nodeSelector:       k8s.#Labels
		serviceAnnotations: k8s.#Annotations
	}

	longhornDriver: {
		priorityClass: string | *null
		tolerations: [...v1.#Toleration]
		nodeSelector: k8s.#Labels
	}

	longhornUI: {
		replicas:      int | *2
		priorityClass: string | *null
		tolerations: [...v1.#Toleration]
		nodeSelector: k8s.#Labels
	}

	longhornAdmissionWebhook: {
		replicas:      int | *2
		priorityClass: string | *null
		tolerations: [...v1.#Toleration]
		nodeSelector: k8s.#Labels
	}

	longhornRecoveryBackend: {
		replicas:      int | *2
		priorityClass: string | *null
		tolerations: [...v1.#Toleration]
		nodeSelector: k8s.#Labels
	}

	ingress: {
		enabled:          bool | *false
		ingressClassName: string | *null
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
