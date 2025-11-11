default:
	@echo "USAGE: make [task]"
	@echo ""
	@echo "  scan      Scan package for issues"
	@echo "  docs      Generate and then open docs"
	@echo "  publish   Publish package and docs to hex.pm"
	@echo "  clean     Clean all project artifacts"
	@echo "  test      Run tests in a container"
	@echo ""

deps:
	@mix deps.get

scan: deps
	@mix src.analyze
	@mix pkg.analyze

docs: deps
	@mix docs
	@show doc/index.html

publish: deps
	@mix hex.publish

clean:
	rm -rf .elixir_ls
	rm -rf _build
	rm -rf deps

ELIXIR_VERS := 1.19.2 1.18.4 1.17.3 1.16.3 1.15.8
ALPINE_TAG := alpine

.PHONY: test
test:
	@for ver in $(ELIXIR_VERS); do \
		tag="tux-test-$$ver"; \
		echo ""; \
		echo "=== Testing with Elixir $$ver ==="; \
		podman build --quiet --build-arg ELIXIR_VERSION=$$ver-$(ALPINE_TAG) -t $$tag .; \
		podman run --rm $$tag; \
	done
