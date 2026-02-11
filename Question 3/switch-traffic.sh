#!/bin/bash

echo "switching to green..."
kubectl patch service hw-two-service -p '{"spec":{"selector":{"version":"green"}}}'

echo "waiting for 3 seconds..."
sleep 3

echo ": status$(kubectl get service hw-two-service)"
kubectl get endpoints hw-two-service

echo "url:"
minikube service hw-two-service --url