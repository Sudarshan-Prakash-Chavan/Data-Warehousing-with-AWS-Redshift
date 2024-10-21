COPY event1 
FROM 's3://samplespectrumbucket/allevents_pipe.txt' 
IAM_ROLE 'arn:aws:iam::846453536904:role/SpectrumRole' 
DELIMITER '|' 
TIMEFORMAT 'YYYY-MM-DD HH:MI:SS' 
REGION 'us-east-1';
