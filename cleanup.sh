kubectl delete -f autoscale.yaml
kubectl delete -f wordpress-deployment.yaml
kubectl delete -f mysql-deployment.yaml
kubectl delete secret mysql-pass
kubectl delete -f local-volumes.yaml