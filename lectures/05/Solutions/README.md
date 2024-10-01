# Lecture 05 - Distributed Data Processing and Distributed Databases

## Exercises

Please open issues [here](https://github.com/jakobhviid/BigDataCourseExercises/issues) if you encounter unclear
information or experience bugs in our examples!

### Exercise 1 - Hive

**Notice**: HDFS is a requirement for this exercise, if you do not have it in your namespace, please set it up before
you continue.

The Hive metastore service will be deployed with PostgreSQL.

```bash
helm install postgresql ^
  --version=12.1.5 ^
  --set auth.username=root ^
  --set auth.password=pwd1234 ^
  --set auth.database=hive ^
  --set primary.extendedConfiguration="password_encryption=md5" ^
  --repo https://charts.bitnami.com/bitnami ^
  postgresql
```

**Task**: Everything required to create the Hive metastore service is now ready. Apply
```bash
kubectl apply -f hive-metastore.yaml
```

**Task**: Apply the [hive.yaml](./hive.yaml) file.

```bash
kubectl apply -f hive.yaml
```

### Exercise 2 - Count words in Alice in Wonderland with Hive


**Task**: Upload Alice in Wonderland file to HDFS if not already done.

1. `exec` into the interactive pod. You can use the pod
   from [exercise 2](#exercise-2---interacting-with-hdfs-cluster-using-cli).
2. Download Alice in Wonderland using `curl -o alice-in-wonderland.txt https://www.gutenberg.org/files/11/11-0.txt`.

3. Create folder `hdfs dfs -fs hdfs://namenode:9000 -mkdir /lecture05`

3. Upload Alice in Wonderland to HDFS using `hdfs dfs -fs hdfs://namenode:9000 -put ./alice-in-wonderland.txt /lecture05`

hdfs dfs -fs hdfs://namenode:9000 -ls /lecture05
**Output**: 
`-rw-r--r--   3 root supergroup     154638 2024-09-30 12:47 /lecture05/alice-in-wonderland.txt`

**Task**: Port-forward Web UI Hive and open the Hive Web UI webpage in your
browser [localhost:10002](http://localhost:10002/).

```bash
kubectl port-forward svc/hiveserver2 10002:10002
```

You should see at least one active session and zero open queries.

**Task**: Port-forward thrift Hive service.

```bash
kubectl port-forward svc/hiveserver2 10000:10000
```


**Tasks:** Open DBeaver and create a new connection database connection using the following steps:

1. Click on the "Database" tab and select "New Database Connection" from the dropdown.
1. Search for Hive and select it, then click "Next" (and install drivers if prompted to).
1. Select "Connect by: URL" and enter the following url: `jdbc:hive2://localhost:10000`.
1. Click on the "Test connection" button to make sure it works properly.
1. If it works, then click on the "Finish" button.

**Task**: Create SQL editor
**Task**: Show all catalogs
```SQL
SHOW TABLES;
```

**Task**: Create a database
```SQL
CREATE
DATABASE IF NOT EXISTS bucket
LOCATION 'hdfs://namenode:9000/user/hive/warehouse/';
```

**Task**: Create a table using the database you just made
```SQL
CREATE TABLE bucket.text
(
    line STRING
) STORED AS TEXTFILE
LOCATION 'hdfs://namenode:9000/<hdfs-directory-location>';
```

We can now query the files inside the specified bucket and folder. Try to select a few lines from the table you just
made.

**Task**: Run the following query `SELECT * FROM bucket.text limit 8;`.

```
|﻿*** START OF THE PROJECT GUTENBERG EBOOK ALICE'S ADVENTURES IN|
|WONDERLAND ***                                                 |
|[Illustration]                                                 |
|                                                               |
|                                                               |
|                                                               |
|                                                               |
|Alice’s Adventures in Wonderland                               |
```

**Task**: Count the total amount of "words" in the Alice in Wonderland text.

```SQL
SELECT SUM(SIZE (SPLIT(line, ' '))) AS word_count
FROM bucket.text;
```
**Output**: `28021`

Below is an explanation of the different functions:

- SPLIT(line, ' '): Splits the string line by spaces, returning an array of words.
- SIZE(array): Returns the size of the array, which in this case is the number of words in each line.
- SUM(): Adds up the total number of words across all rows in the table.

**Task**: Find the 10 most used words in the Alice in Wonderland text.

```SQL
SELECT word, COUNT(*) AS count
FROM (
    SELECT EXPLODE(SPLIT(line, ' ')) AS word
    FROM bucket.text
    ) temp
GROUP BY word
ORDER BY count DESC
    LIMIT 10;
```

1. SPLIT(line, ' '): splits each line into words based on spaces, returning an array of words.
1. EXPLODE(): takes an array (in this case, the array of words from SPLIT) and turns each element into a separate row.
   This way, each word from the line is now treated as a row.
1. GROUP BY word: After exploding the array of words, we group by each unique word.
1. COUNT(*): This counts how many times each word appears in the dataset.
1. ORDER BY count DESC: Orders the words by their count in descending order, so the most frequent words appear first.
1. LIMIT 10: Limits the result to the 10 most frequent words.


Just as an added bonus, you can actually get the name of files using `input__file__name`. For example, try executing the
following SQL statement:
```SQL
SELECT input__file__name AS path, SUM(SIZE (SPLIT(line, ' '))) AS word_count
FROM bucket.text
GROUP BY input__file__name;
```

You can also filter by the path:
```SQL
SELECT SUM(SIZE (SPLIT(line, ' '))) AS word_count
FROM bucket.text
WHERE input__file__name = 'hdfs://namenode:9000/lecture05/alice-in-wonderland.txt';
```
This one will only count the amount of words for files that match a specific path.



### Exercise 3 - Backblaze Hard Drive Data

**Task**: Download drive data for 2023 Q2.
    - [Link to file](https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q2_2023.zip)

Create a new folder inside the HDFS and upload the `2023-06-30.csv` file to it.
```bash
hdfs dfs -fs hdfs://namenode:9000 -mkdir /lecture05/DriveData
```

**Task**: Upload drive data for 30/6/2023 into the new folder inside HDFS.
```bash
hdfs dfs -fs hdfs://namenode:9000 -put ./2023-06-30.csv /lecture05/DriveData
```

**Task**: Create a table for the Backblaze drive data.
```SQL
CREATE
EXTERNAL TABLE IF NOT EXISTS bucket.backblaze (
  `date` STRING,
  serial_number STRING,
  model STRING,
  capacity_bytes STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'hdfs://namenode:9000/lecture05/DriveData/'
TBLPROPERTIES (
  'skip.header.line.count'='1'
);
```

The format is CSV. We skip 1 header line because we don't want to include the header with column names as part of the
dataset.

**Task**: Get the first 100 rows of the CSV file.
```SQL
SELECT * FROM bucket.backblaze limit 100;
```

**Tasks:** Answer the following questions using Hive

- What is the total count of each model of hard drive?
- What is the capacity of the different hard drive models?
- What is the total capacity of each model of hard drive?
- What hard drive model is the most used?
- What hard drive model has the largest total capacity?

```SQL
SELECT model,
       FLOOR(CAST(capacity_bytes AS BIGINT) / POWER(10, 9))                   AS capacity_gigabytes,
       SUM(FLOOR(CAST(capacity_bytes AS BIGINT) / POWER(10, 9))) / 1000 AS total_capacity_terabytes,
       COUNT(*) AS count
FROM bucket.backblaze
WHERE input__file__name = 'hdfs://namenode:9000/lecture05/DriveData/2023-06-30.csv'
GROUP BY model, capacity_bytes
ORDER BY count DESC;
```

**Tasks:** Compare the results to the [blog post about the drive stats](https://www.backblaze.com/blog/backblaze-drive-stats-for-q2-2023/). For example,
the drive model `TOSHIBA MG07ACA14TA` is the most used with 38101 total drives. This is the same amount as what
Backblaze shows in their blog post.

![drive data legend](Images/drive_data_legend.png)
![TOSHIBA_MG07ACA14TA.png](Images/TOSHIBA_MG07ACA14TA.png)

