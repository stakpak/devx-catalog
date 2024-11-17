package stacks

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/k8s/services/pixie"
)
Pixie: v1.#Stack & {
	$metadata: stack: "Pixie"
	components: {
        "pixie": pixie.#PixieChart & {
			helm: {
				version: string | *"0.1.6"
				release: "pixie"
				values: {}
            }
        }
    }
}