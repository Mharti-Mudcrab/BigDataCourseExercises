@echo off

echo ========== Deploy a Kafka cluster - Ref: Lecture 3 Exercise 1 ==========
helm install --values kafka-values.yaml kafka oci://registry-1.docker.io/bitnamicharts/kafka --version 30.0.4
kubectl run kafka-client --restart=Never --image docker.io/bitnami/kafka:3.8.0-debian-12-r3  --command -- sleep infinity

echo ========== Deploy a Kafka Connect, Kafka Schema Registry, and Kafka KSQL - Ref: Lecture 3 Exercise 2 ==========
cd /d %~dp0\..\lectures\03
kubectl apply -f kafka-schema-registry.yaml 
kubectl apply -f kafka-connect.yaml
kubectl apply -f kafka-ksqldb.yaml

echo ========== Deploy Redpanda - Ref: Lecture 3 Exercise 3 ==========
cd /d %~dp0\..\lectures\03
kubectl apply -f redpanda.yaml
setlocal
:: Define the path for the temporary file
set "tempFile=%TEMP%\autoexec_temp.bat"
:: Write content to the temporary file
(
	echo @echo off
    echo echo Access Redpanda with: http://127.0.0.1:8080
	echo echo Waiting for pod Ready ^(timeout=10s^) . . .
    echo kubectl wait --for=condition=Ready pod -l app=redpanda --timeout=10s
	echo echo Start port-forward
	echo kubectl port-forward svc/redpanda 8080
) > "%tempFile%"
:: Execute the temporary file in a new terminal window
start "" "%tempFile%"
endlocal

echo ========== Deploy HDFS - Ref: services\hdfs ==========
cd /d %~dp0\..\services\hdfs
kubectl apply -f configmap.yaml
kubectl apply -f namenode.yaml
echo Waiting for namenode condition Ready (timeout=10s) . . .
kubectl wait --for=condition=Ready pod -l app=namenode --timeout=10s
kubectl apply -f datanodes.yaml
:: Optional hdfs-cli
kubectl apply -f hdfs-cli.yaml

echo ========== Deploy interactive pod - Ref: services\interactive - Alt. apache/hadoop:3 Ref: lecture 2 Exercise 2 ==========
cd /d %~dp0\..\services\interactive
start cmd /k "echo Interactive pod! & kubectl run interactive -i --tty --image registry.gitlab.sdu.dk/jah/bigdatarepo/interactive:latest -- /bin/bash"
::start cmd /k "echo Interactive hadoop:3 pod! & kubectl run hadoop3 -i --tty --image apache/hadoop:3 -- /bin/bash"


pause