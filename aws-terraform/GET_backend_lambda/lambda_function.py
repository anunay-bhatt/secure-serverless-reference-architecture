import boto3
from botocore.exceptions import ClientError
import os

backend_table_name = os.environ.get('BACKEND_TABLE_NAME')

def lambda_handler(event, context):
    
    print("Received following event:{}".format(event))
    if ("org" in event['params']['querystring']):
        org = event['params']['querystring']["org"];
        print("Received org : {}".format(org)); 
        
    else:
        print("No input provided")
        return { "error" : "no org received"}
        
    value = get_vuln(org)
    if value:
        print("Get vulnerabilities for org succeded:")
        return {org: value}
    else:
        print("No value found")
        
def get_vuln(org):
    
    dynamodb = boto3.client('dynamodb',region_name='us-west-2')
    
    try:
        resp = dynamodb.query(
           TableName=backend_table_name,
           IndexName='OrgIndex',
           ExpressionAttributeValues={
               ':v1': {
                   'S': org,
               },
           },
           KeyConditionExpression='Org = :v1',
        )
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        items = resp.get('Items')
        return items