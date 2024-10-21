# Data-Warehousing-with-AWS-Redshift

**Overview**

This project demonstrates the setup and configuration of a data warehousing solution using AWS Redshift and S3. 
It includes the creation of IAM roles, S3 bucket setup, Redshift cluster configuration, data loading, and SQL query execution to analyze data.

**Features** 

1  Create and configure an AWS Redshift cluster 

2  Load data from S3 into Redshift 

3  Execute SQL queries for data analysis 

4  Unload data from Redshift back to S3 

5  Use AWS Glue for data cataloging

**Architectural Diagram**

**Prerequisites**

1  An active AWS account 

2  Basic knowledge of AWS services and SQL 

3  AWS CLI (optional for command line operations)

**Step 1: Create IAM Role**

**1 Navigate to IAM Console**

  Go to the AWS Management Console and search for IAM.

**2 Create a Role**

  Click on Roles and then Create role.

**3 Select Trusted Entity**

  Choose AWS Service, select Redshift, and use case as "Redshift - Customizable".

**4 Attach Permissions**

  Attach the following permissions:

>  AmazonS3ReadOnlyAccess 

>  AWSGlueConsoleFullAccess

5 Complete Role Creation Name the role SpectrumRole and click Create role. Copy the Role ARN for later use.

**Step 2: Create S3 Bucket**

**1 Navigate to S3 Console**

  Search for S3 in the AWS Management Console.

**2 Create a Bucket** 

  Click on Create bucket and name it samplespectrumbucket. Configure settings as needed and click Create.

**3 Upload Sample Data**

  Upload sample files (e.g., allevents_pipe.txt) to the S3 bucket.

**Step 3: Create Redshift Cluster**

**1 Search for Redshift Service**

  Go to the AWS Management Console and search for Redshift.

**2 Create Cluster**

  Click on Clusters and then Create cluster.

**3 Cluster Configuration**

  Fill in:
  
  >  Cluster Identifier: MyRedshiftCluster

  >  Database Name: dev

  >  Master Username: awsuser

  >  Password: [admin user password used at the time of cluster creation]

**4 Network Settings**

Configure the network settings under Additional Configuration.

**5 Create Cluster**

Click Create cluster. It may take 8 to 10 minutes for the cluster to be ready.

**Step 5: Access the Query Editor**

**1 Open the Query**

Editor Click on the Query Editor in the Redshift console.

**2 Connect to Database**

Use the credentials (username: awsuser, password: [used at the time of redshift cluster creation]) to connect.

**Step 6: Create the Event Table**

Run SQL Command to Create Table:

>  CREATE TABLE event1

> ( eventid INTEGER NOT NULL DISTKEY,

> venueid SMALLINT NOT NULL,

> catid SMALLINT NOT NULL,

> dateid SMALLINT NOT NULL SORTKEY,

> eventname VARCHAR(200),

> starttime TIMESTAMP );

**Step 7: Load Data from S3 to Redshift Use COPY Command:**

> COPY event1 FROM 's3://samplespectrumbucket/allevents_pipe.txt' ##S3 Bucket path

> IAM_ROLE 'arn:aws:iam::846453536904:role/SpectrumRole' ##IAM role created to access s3 bucket

> DELIMITER '|' TIMEFORMAT 'YYYY-MM-DD HH:MI:SS' REGION 'us-east-1';

**Step 8: Unload Data from Redshift to S3 Unload Command:**

> UNLOAD ('SELECT * FROM event1 WHERE catid = 7')

> TO 's3://samplespectrumbucket/offloaded/' ##S3 Bucket path

> IAM_ROLE 'arn:aws:iam::846453536904:role/SpectrumRole' ##IAM role created to access s3 bucket.

> PARALLEL OFF; ##PARALLEL is off as small amount of data being tranferred.

**Step 9: Create External Schema and Tables**

**1 Create External Schema:**

> CREATE EXTERNAL SCHEMA

> spectrum FROM DATA CATALOG DATABASE 'spectrumdb'

> IAM_ROLE 'arn:aws:iam::846453536904:role/SpectrumRole'

> create external database if not exists;

**2 Create External Table:**

> CREATE EXTERNAL TABLE

> spectrum.sales1 ( salesid INTEGER,
> listid INTEGER,
> sellerid INTEGER,
> buyerid INTEGER,
> eventid INTEGER,
> dateid SMALLINT,
> qtysold SMALLINT,
> pricepaid DECIMAL(8,2),
> commission DECIMAL(8,2),
> saletime TIMESTAMP )

> ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'

> STORED AS TEXTFILE

> LOCATION 's3://samplespectrumbucket/spectrum/sales/'

> TABLE PROPERTIES ('numRows'='172000');

##Sales is the name of table and spectrum schema is applied. Specify approximate number of rows as 172000. Examine number of rows in sales_tab.txt 

##Ensure that sales_tab.txt is available at s3://samplespectrumbucket/spectrum/sales/

**Step 10: Verify in AWS Glue**

**Navigate to AWS Glue Console**

Check Data Catalog -> Databases -> spectrumDB -> tables -> sales for columns.

**Step 11: Query the Data on Redshift Query Editor Window**

**1 Count Rows in External Table:**

>  SELECT COUNT(*) FROM spectrum.sales1;

**2 Sample Data from External Table:**

>  SELECT * FROM spectrum.sales1 LIMIT 3;

**3 Join Query Example:**

> SELECT event1.eventname AS event_name, SUM(spectrum.sales1.pricepaid) AS gross_ticket_sales

> FROM spectrum.sales1, event1

> WHERE spectrum.sales1.eventid = event1.eventid

> AND spectrum.sales1.pricepaid > 30

> GROUP BY event1.eventname ORDER BY 2 DESC;
