default:
	@echo "USAGE: make [task]"
	@echo ""
	@echo "  scan      Scan package for issues"
	@echo "  docs      Generate and then open docs"
	@echo "  publish   Publish package and docs to hex.pm"
	@echo ""

scan:
	@mix src.analyze
	@mix pkg.analyze

docs:
	@mix docs
	@show doc/index.html

publish:
	@mix hex.publish
