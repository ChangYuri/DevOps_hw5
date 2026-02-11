#!/bin/bash
# update-demo.sh

echo "rolling update "

echo "version now:"
kubectl get pods -l app=nginx 


echo -e "\nupdating: nginx:1.14.2 → nginx:1.19"
kubectl set image deployment/nginx-deployment nginx=nginx:1.18

echo "waiting for rollout to complete..."
timeout 90 kubectl rollout status deployment/nginx-deployment 

echo -e "\nversion after update:"
kubectl get pods -l app=nginx 

echo -e "done"

# https://minikube.sigs.k8s.io/docs/tutorials/kubernetes_101/module6/

echo -e "rollback example"
kubectl set image deployment/nginx-deployment nginx=nginx:wrongversion
kubectl get pods -l app=nginx
echo -e "rolling back"
kubectl rollout undo deployment/nginx-deployment
kubectl get pods -l app=nginx

minikube service hw-one-service --url