@echo off

echo ========== Deploy a Kafka Connect, Kafka Schema Registry, and Kafka KSQL - Ref: Lecture 3 Exercise 2 ==========
cd /d %~dp0\..\lectures\03
kubectl apply -f kafka-schema-registry.yaml 
kubectl apply -f kafka-connect.yaml
kubectl apply -f kafka-ksqldb.yaml


pause