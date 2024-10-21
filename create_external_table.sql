CREATE EXTERNAL TABLE spectrum.sales1 (
    salesid INTEGER,
    listid INTEGER,
    sellerid INTEGER,
    buyerid INTEGER,
    eventid INTEGER,
    dateid SMALLINT,
    qtysold SMALLINT,
    pricepaid DECIMAL(8,2),
    commission DECIMAL(8,2),
    saletime TIMESTAMP
)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t' 
STORED AS TEXTFILE 
LOCATION 's3://samplespectrumbucket/spectrum/sales/' 
TABLE PROPERTIES ('numRows'='172000');
