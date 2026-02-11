#!/usr/bin/env bash
set -euo pipefail

# Very small and simple canary script
# Usage:
#   ./canary-promotion.sh 80       # set canary weight to 80%

INGRESS_NAME=${INGRESS_NAME:-canary}
NAMESPACE=${NAMESPACE:-default}
TARGET=${1:-50}
MODE=${2:-}
PF_PORT=${PF_PORT:-18090}
INGRESS_HOST=${INGRESS_HOST:-nginx.local}
VERIFY_REQS=${VERIFY_REQS:-40}

function die { echo "$*" >&2; exit 1; }

command -v kubectl >/dev/null 2>&1 || die "kubectl required"
# define die function

echo "Setting canary weight -> ${TARGET}% (ingress/${INGRESS_NAME} in ${NAMESPACE})"
kubectl annotate ingress ${INGRESS_NAME} -n ${NAMESPACE} \
  nginx.ingress.kubernetes.io/canary-weight="${TARGET}" --overwrite
# change the weights


kubectl port-forward -n ingress-nginx service/ingress-nginx-controller ${PF_PORT}:80 --address 127.0.0.1 >/dev/null 2>&1 &
PF_PID=$!
trap 'kill ${PF_PID} >/dev/null 2>&1 || true' EXIT
sleep 1
seq ${VERIFY_REQS} | xargs -n1 -P10 -I{} curl -s -H "Host: ${INGRESS_HOST}" "http://127.0.0.1:${PF_PORT}/" || true | sort | uniq -c | awk -v n=${VERIFY_REQS} '{printf "%d %s (%.1f%%)\n", $1, $2, 100*$1/n}'
kill ${PF_PID} >/dev/null 2>&1 || true
trap - EXIT

echo "Done."
