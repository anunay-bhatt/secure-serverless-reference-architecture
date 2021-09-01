import json
import boto3
from botocore.exceptions import ClientError
import os

authorizer_table_name = os.environ.get('POST_AUTHORIZER_TABLE_NAME')

def lambda_handler(event, context):
    
    print(event)
    client = get_OU(event)
    print(client)
    authorized_client = get_authorized_client(client)

    print("Checking if Client: {} is authorized to use POST API".format(client))
    if(authorized_client):
        print("Auhtorization successfull")
        return {
            "principalId": "client",
            "policyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                {   
                    "Action": "execute-api:Invoke",
                    "Effect": "Allow"
                }
                ]
            }
        }
        
def get_OU(event):
    subjectDN = event['requestContext']['identity']['clientCert']['subjectDN']
    for item in subjectDN.split(","):
        if(item.find("OU") == 0):
            OU = item.split("=")[1]
    return OU

def get_authorized_client(client):
    
    dynamodb = boto3.resource('dynamodb',region_name='us-west-2')
        
    table = dynamodb.Table(authorizer_table_name)
    try:
        response = table.get_item(Key={'Client': client})
        print(response)
    except ClientError as e:
        print(e.response['Error']['Message'])
        print("Auhtorization denied")
        return {
            "principalId": "client",
            "policyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                {   
                    "Action": "execute-api:Invoke",
                    "Effect": "Deny"
                }
                ]
            }
        }
    else:
        if('Item' in response):
            return response['Item']
        else:
            print("Auhtorization denied")
            return {
                "principalId": "client",
                "policyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                    {   
                        "Action": "execute-api:Invoke",
                        "Effect": "Deny"
                    }
                    ]
                }
            }