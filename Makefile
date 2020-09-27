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

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[1;34m%-20s\033[0m %s\n", $$1, $$2}'

