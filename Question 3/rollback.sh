#!/bin/bash

echo "rolling back to blue..."
kubectl patch service hw-two-service -p '{"spec":{"selector":{"version":"blue"}}}'

echo "rollback complete"