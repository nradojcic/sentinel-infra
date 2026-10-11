.PHONY: help init plan apply destroy fmt validate lint bootstrap kube-context

ENV_DIR := environments/dev

help:
	@echo "Targets:"
	@echo "  make init       - terraform init"
	@echo "  make plan       - terraform plan"
	@echo "  make apply      - terraform apply"
	@echo "  make destroy    - terraform destroy"
	@echo "  make fmt        - terraform fmt -recursive"
	@echo "  make validate   - terraform validate"
	@echo "  make lint       - tflint (if installed)"
	@echo "  make bootstrap  - start Minikube and run full deploy"
	@echo "  make kube-context - eval Minikube docker-env for local images"

init:
	cd $(ENV_DIR) && terraform init

plan:
	cd $(ENV_DIR) && terraform plan

apply:
	cd $(ENV_DIR) && terraform apply

destroy:
	cd $(ENV_DIR) && terraform destroy

fmt:
	terraform fmt -recursive

validate:
	cd $(ENV_DIR) && terraform validate

lint:
	@command -v tflint >/dev/null 2>&1 && tflint --recursive || echo "tflint not installed, skipping"

kube-context:
	@echo "Run this in your shell: eval \$$(minikube -p minikube docker-env)"

bootstrap:
	./scripts/bootstrap.sh
