.PHONY=init
init: ## Install tools and shit
	shards check || shards install
	cd lib/icr/; make build

.PHONY=console
console: ## Start a console
	@./lib/icr/bin/icr

.PHONY=test
test: ## Run the tests
	crystal spec --order random --error-trace

.PHONY=format
format: ## Format all Crystal files
	crystal tool format src/

.PHONY=publish
publish: ## Publish the shard
	@echo 'Current version from last tag: '
	@echo $(shell git describe --tags)
	@echo
	@read -p "Version? " VERSION; \
	sed -i '' -e "s/^version:.*$$/version: $$VERSION/g" shard.yml; \
	sed -i '' -e "s/version: ~> .*$$/version: ~> $$VERSION/g" README.md; \
	git add shard.yml; \
	git commit -m "Bump version: $$VERSION"; \
	git tag v$$VERSION; \
	git push; \
	git push --tags

.PHONY=help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[1;34m%-20s\033[0m %s\n", $$1, $$2}'

