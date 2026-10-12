.PHONY: help init plan apply destroy fmt validate lint bootstrap kube-context dashboard status logs-agent logs-server

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
	@echo "  make dashboard     - port-forward the Sentinel dashboard on :8080 (blocking)"
	@echo "  make status        - kubectl get pods,svc,configmap in sentinel-system"
	@echo "  make logs-agent    - tail agent logs"
	@echo "  make logs-server   - tail server logs"

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

dashboard:
	@echo "Starting port-forward to Sentinel dashboard..."
	@echo "Open http://localhost:8080 in your browser. Ctrl+C to stop."
	kubectl port-forward -n sentinel-system svc/sentinel-server 8080:8080

status:
	kubectl get pods,svc,configmap -n sentinel-system

logs-agent:
	kubectl logs -n sentinel-system deploy/sentinel-agent --tail=50 -f

logs-server:
	kubectl logs -n sentinel-system deploy/sentinel-server --tail=50 -f
