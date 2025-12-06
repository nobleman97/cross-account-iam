import boto3
import os
import urllib3
import json
from datetime import datetime

def lambda_handler(event, context):
    account2_role_arn = os.environ['ACCOUNT2_ROLE_ARN']
    bucket_name = os.environ['BUCKET_NAME']
    bucket_region = os.environ['BUCKET_REGION']
    object_key = 'iss_position.txt'
    local_file_path = f'/tmp/{object_key}'

    # Step 1: Assume role in Account 2
    sts_client = boto3.client('sts')
    
    assumed_role = sts_client.assume_role(
        RoleArn=account2_role_arn,
        RoleSessionName='LambdaCrossAccountS3Access'
    )

    # Step 2: Extract credentials
    credentials = assumed_role['Credentials']

    # Step 3: Create S3 client with assumed credentials
    s3_client = boto3.client(
        's3',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken'],
        region_name=bucket_region  # or your bucket's region
    )

    # Step 4: Read from S3 and store as local file in /tmp
    try:
        response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
        content = response['Body'].read().decode('utf-8')
        with open(local_file_path, 'w') as file:
            file.write(content)
        print(f"Successfully pulled and stored {object_key} from S3 to {local_file_path}")
    except Exception as e:
        print(f"Error reading from S3: {e}")
        raise

    # Step 5: Fetch ISS position and write to local file in /tmp
    try:
        http = urllib3.PoolManager()
        response = http.request("GET", "http://api.open-notify.org/iss-now.json")
        data = json.loads(response.data.decode("utf-8"))
        timestamp = datetime.fromtimestamp(data['timestamp'])

        with open(local_file_path, "a") as file:
            file.write(f"Time: {timestamp}\n")
            file.write(f"Latitude: {data['iss_position']['latitude']}\n")
            file.write(f"Longitude: {data['iss_position']['longitude']}\n")
            file.write("\n")
        print("Successfully appended ISS position data to local file")
    except Exception as e:
        print(f"Error fetching ISS position or writing to file: {e}")
        raise

    # Step 6: Push file back to S3 with original filename
    try:
        with open(local_file_path, 'r') as file:
            file_content = file.read()
        s3_client.put_object(
            Bucket=bucket_name,
            Key=object_key,
            Body=file_content
        )
        print(f"Successfully pushed {object_key} back to S3")
    except Exception as e:
        print(f"Error writing to S3: {e}")
        raise

    return { 
        'statusCode': 200,
        'body': 'Cross-account S3 access test complete.'
    }