.PHONY: test
test:
	@cue eval ./...
	@cd test && cue eval


.PHONY: build
build: 
	@rm -Rf pkg
	@mkdir -p pkg/stakpak.dev/devx
	@cp -R v1 pkg/stakpak.dev/devx/v1
	@cp -R v2alpha1 pkg/stakpak.dev/devx/v2alpha1
	@cp -R cue.mod/pkg/* pkg/