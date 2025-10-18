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

.PHONY: test
test:
	podman build -t tux-test .
	podman run --rm tux-test
