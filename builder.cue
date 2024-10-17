package main

import (
    "stakpak.dev/devx/v2alpha1"
    "stakpak.dev/devx/v1/transformers/terraform/aws"
    "stakpak.dev/devx/v1/transformers/terraform/k8s"
    "stakpak.dev/devx/v1/transformers/terraform/helm"
)

builders: v2alpha1.#Environments & {
    prod: {
        flows: {
            // Pipeline for adding EKS Cluster
            "eks/add-cluster": pipeline: [
                aws.#AddKubernetesCluster
            ]

            // Helm Configuration and Release Pipeline
            "terraform/helm": pipeline: [
                k8s.#AddLocalHelmProvider,
                helm.#AddHelmRelease,
            ]
        }
    }
}