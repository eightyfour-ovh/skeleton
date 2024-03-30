.DEFAULT_GOAL := help

.PHONY: docker
docker: ## Create docker image and a standalone container for dev environment
	@docker compose -f docker-compose.yml up --build -d

.PHONY: clean
clean: ## Safely remove docker container
	@docker compose down --rmi local -v

.PHONY: composer
composer: ## Install Composer inside php8 docker image (composer-setup.sh is needed)
	@docker exec -it symfony sh -c "/app/composer-setup.sh"

.PHONY: help
help: ## This help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
