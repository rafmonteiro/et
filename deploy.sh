#!/bin/bash
kubectl create -f local-volumes.yaml
kubectl create secret generic mysql-pass --from-file=password.txt
kubectl create -f mysql-deployment.yaml
kubectl create -f wordpress-deployment.yaml
kubectl create -f autoscale.yaml

MYSQL_POD_NAME=$(kubectl get pods |grep -E mysql| grep Running |awk '{print $1 }')
MYSQL_POD_IP=$(kubectl describe pod $MYSQL_POD_NAME | grep IP | awk '{ print $2 }')
MYSQL_PASSWORD=$(cat password.txt)
echo "waiting for mysql pod to come up"
while [[ $MYSQL_POD_NAME = '' ]] 
    do  
        sleep 5;
        echo -n "."
        MYSQL_POD_NAME=$(kubectl get pods |grep -E mysql| grep Running |awk '{print $1 }')
   done
   echo ""

WORDPRESS_POD_NAME=$(kubectl get pods |grep -Ev mysql| grep Running |awk '{print $1 }')
echo "waiting for Wordpress pod to come up"
while [[ $WORDPRESS_POD_NAME = '' ]] 
    do 
        sleep 5;
        echo -n "."
        WORDPRESS_POD_NAME=$(kubectl get pods |grep -Ev mysql| grep Running |awk '{print $1 }')
   done
   echo ""

 # Find mysql container name, download dump file and use docker to restore it!
 
MYSQL_CONTAINER=$(minikube ssh "docker ps |grep mysql |grep entrypoint" |awk '{print $1}')
DUMP_URL="https://raw.githubusercontent.com/rafmonteiro/et/master/dump.sql"
WP_URL=$(minikube service wordpress --url |sed 's/^http\(\|s\):\/\///g')
minikube ssh "curl -O $DUMP_URL; sed -i -e 's/192.168.99.101:30106/$WP_URL/g' dump.sql"
#minikube ssh "cat dump.sql | docker exec -i $MYSQL_CONTAINER /usr/bin/mysql -uroot --password=supersecret"
sleep 5
minikube ssh "docker exec -i $MYSQL_CONTAINER /usr/bin/mysql -uroot --password=supersecret wordpress < dump.sql"
 
echo "open $(minikube service wordpress --url)/p?=5  on your browser" 