.PHONY: test
test:
	@cd test && cue eval


.PHONY: build
build: 
	@rm -Rf pkg
	@mkdir -p pkg/guku.io/devx
	@cp -R v1 pkg/guku.io/devx/v1
	@cp -R v2alpha1 pkg/guku.io/devx/v2alpha1
	@cp -R cue.mod/pkg/* pkg/