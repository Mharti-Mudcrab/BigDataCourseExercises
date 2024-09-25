### Exercise 1 - Deploying Apache Spark on Kubernetes

**Task**: Install the Spark Helm chart using the following command:

```bash
helm install --values spark-values.yaml spark oci://registry-1.docker.io/bitnamicharts/spark --version 9.2.10
```

**Task**: Inspect the UI of the Spark deployment and validate that there are two worker nodes alive.

```bash
kubectl port-forward svc/spark-master-svc 8080:80
```

![Spar web application](lectures\04\Solutions\Images\SparkWebClient.png)


### Exercise 2 - Running a Spark job locally and in your deployment

**Task**: Run the [pi-estimation.py](./pi-estimation.py) file locally using Python 3.12.

- How will the number of partitions argument affect the result?<br/>
  The result becomes more precise.

**Task**: Update the [pi-estimation.py](./pi-estimation.py) file to be executed on the inside your Kubernetes cluster.

- Does the number of partitions affect the runtime?<br/>
  it takes longer
- How does the runtime compare to running the program locally?<br/>
  It is twice as fast because we have two workers that can work of the operation in parallel.


### Exercise 3 - Analyzing files using Spark jobs

*prerequisite*: **Start HDFS Service**

[HDFS Service](C:\GitHubDesctopRepositories\MhartiBigDataCourseExercises\services\hdfs)
```
kubectl apply -f configmap.yaml
```
```
kubectl get configmap hadoop-config
```
```
kubectl apply -f namenode.yaml
```
```
kubectl apply -f datanodes.yaml
```

**Task**: Ensure the [alice in wonderland](https://www.gutenberg.org/files/11/11-0.txt) file is within your HDFS
cluster. If not upload the file to HDFS.

```
curl -o alice-in-wonderland.txt https://www.gutenberg.org/files/11/11-0.txt
```
```
hdfs dfs -fs hdfs://namenode:9000 -put ./alice-in-wonderland.txt /
```

**Task**: Inspect the [word-count.py](./word-count.py). The program counts the occurrences of all unique "words" in the
input file.

**Output**: 
```
Top 10 words in alice-in-wonderland.txt are:
the: 1515
: 1472
and: 717
to: 706
a: 611
of: 493
she: 485
said: 416
it: 347
in: 346
```


