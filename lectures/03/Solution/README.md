#Lecture 3 solutions

## Exercise 1 - Deploy a Kafka cluster

**Task**: Deploy Kafka using the `helm` and the following [kafka-values.yaml](kafka-values.yaml) file.


```bash
helm install --values kafka-values.yaml kafka oci://registry-1.docker.io/bitnamicharts/kafka --version 30.0.4
```

#### Validate the deployment of Kafka using a simple producer and consumer

**Tasks**: Producing and consuming topic messages

1. Create a Kafka client pod (`docker.io/bitnami/kafka:3.8.0-debian-12-r3`) using `kubectl run`.

```bash
kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.8.0-debian-12-r3  --command -- sleep infinity
```

2. Open two terminals and attach to the Kafka client pod using `kubectl exec` command.

```bash
kubectl exec --tty -i kafka-client -- bash
```

3. Run the following commands in the first terminal to produce messages to the Kafka topic `test`:

```bash
kafka-console-producer.sh --bootstrap-server kafka:9092 --topic test
```

**Output**:
```
D:\Programmer\GitHub Repositories\BigDataCourseExercises\lectures\03>kubectl exec --tty -i kafka-client -- bash
I have no name!@kafka-client:/$ kafka-console-producer.sh --bootstrap-server kafka:9092 --topic test
>Hej
>Dette er text
>345324564578469
```

4. Run the following commands in the second terminal to consume messages from the Kafka topic `test`:

```
kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic test --from-beginning
```

**Output**:
```
C:\Users\madsw>kubectl exec --tty -i kafka-client -- bash
I have no name!@kafka-client:/$ kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic test --from-beginning
Hej
Dette er text
345324564578469
```


### Exercise 2 - Additional deployments of Kafka Connect, Kafka Schema Registry, and Kafka KSQL

1. Apply the Kafka Schema Registry manifest file to your namespace. ```bash kubectl apply -f kafka-schema-registry.yaml ```
1. Apply the Kafka Connect module to your namespace. ```bash kubectl apply -f kafka-connect.yaml```
1. Apply the Kafka Ksqldb server to your namespace. ```bash kubectl apply -f kafka-ksqldb.yaml```
1. Toggle the following values in the redpanda config map ([redpanda.yaml](./redpanda.yaml)) to enable Kafka modules.
    - `KAFKA_SCHEMAREGISTRY_ENABLED`=`true`
    - `CONNECT_ENABLED`=`true`