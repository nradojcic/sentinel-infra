#!/usr/bin/env bash
set -euo pipefail

# Always run from the scripts/ directory so relative paths are predictable
cd "$(dirname "${BASH_SOURCE[0]}")"

# --- Paths ------------------------------------------------------------------
# Path to the Sentinel Go source repo (a sibling checkout, not inside this repo)
# Override by exporting SENTINEL_SRC before running the script
SENTINEL_SRC="${SENTINEL_SRC:-$HOME/Documents/Code/go-src/2026-02-distributed-comm-syst/sentinel}"

# Terraform environment directory, relative to scripts/
TERRAFORM_ENV="../environments/dev"

# --- Deployment config ------------------------------------------------------
NAMESPACE="sentinel-system"

# --- Pre-flight checks ------------------------------------------------------
for cmd in minikube kubectl docker terraform; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: $cmd is not installed or not in PATH"
        exit 1
    fi
done

if [ ! -d "$TERRAFORM_ENV" ]; then
    echo "ERROR: Terraform environment dir not found: $TERRAFORM_ENV"
    echo "    Expected path is relative to scripts/. Check that the script is"
    echo "    in <repo-root>/scripts/ and that <repo-root>/environments/dev exists."
    exit 1
fi

# --- Start Minikube ---------------------------------------------------------
echo "==> Checking Minikube status..."
if ! minikube status >/dev/null 2>&1; then
    echo "    Starting Minikube..."
    minikube start --driver=docker
fi

# --- Point shell at Minikube's Docker daemon --------------------------------
echo "==> Configuring shell to use Minikube's Docker daemon..."
eval "$(minikube -p minikube docker-env)"

# --- Build Sentinel images --------------------------------------------------
if [ -d "$SENTINEL_SRC" ]; then
    echo "==> Building Sentinel images from $SENTINEL_SRC..."
    (cd "$SENTINEL_SRC" && docker build -f Dockerfile.server -t sentinel-server:dev .)
    (cd "$SENTINEL_SRC" && docker build -f Dockerfile.agent  -t sentinel-agent:dev  .)
else
    echo "==> WARNING: Sentinel source not found at $SENTINEL_SRC"
    echo "    Assuming sentinel-server:dev and sentinel-agent:dev already exist"
    echo "    in Minikube's Docker daemon. To build from a different checkout:"
    echo "        SENTINEL_SRC=/path/to/sentinel make bootstrap"
fi

# Verify both images are present in Minikube's daemon
for img in sentinel-server:dev sentinel-agent:dev; do
    if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -qx "$img"; then
        echo "ERROR: image $img not found in Minikube's Docker daemon"
        echo "    Did the build step fail silently? Check 'docker images'."
        exit 1
    fi
done

# --- Terraform --------------------------------------------------------------
echo "==> Running terraform init..."
(cd "$TERRAFORM_ENV" && terraform init -upgrade)

echo "==> Applying Terraform..."
(cd "$TERRAFORM_ENV" && terraform apply -auto-approve)

# --- Wait for workloads -----------------------------------------------------
echo "==> Waiting for sentinel-server to be ready..."
kubectl wait --for=condition=Ready pod -l app=sentinel-server -n "$NAMESPACE" --timeout=180s

echo "==> Waiting for sentinel-agent pods to be ready..."
kubectl wait --for=condition=Ready pod -l app=sentinel-agent -n "$NAMESPACE" --timeout=180s

# --- Summary ----------------------------------------------------------------
echo ""
echo "==> Deployment status:"
kubectl get pods,svc,configmap -n "$NAMESPACE"

echo ""
echo "==> Sentinel platform provisioned successfully."
echo ""
echo "    To view the dashboard, run in a separate terminal:"
echo "        make dashboard          # port-forwards 8080"
echo "    Then open http://localhost:8080 in your browser."
