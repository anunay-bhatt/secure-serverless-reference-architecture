import json
import boto3
from botocore.exceptions import ClientError
import os

authorizer_table_name = os.environ.get('POST_AUTHORIZER_TABLE_NAME')

def lambda_handler(event, context):
    
    client = get_OU(event)

    if 'methodArn' not in event:
        print("could not find 'methodArn' key in event")
        return generate_policy(client, 'Deny', '')
        
    # Since this is a demo deployment, I am not verifying the Issuer of the client certificate
    # For Production systems, Issuer OU and CN need to be verified before validating the client subject OU
    print("Checking if Client: {} is authorized to use POST API".format(client))
    authorized_client = get_authorized_client(client)
    if(authorized_client):
        print("Authorization successfull")
        return generate_policy(client, 'Allow', event['methodArn'])
    else:
        print("Authorization denied")
        return generate_policy(client, 'Deny', event['methodArn'])
        
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
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        if('Item' in response):
            return response['Item']

def generate_policy(principal_id: str, effect: str, method_arn):
    authResponse = {}
    authResponse['principalId'] = principal_id

    if effect and method_arn:
        policyDocument = {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Action': 'execute-api:Invoke',
                    'Effect': effect,
                    'Resource': method_arn
                }
            ]
        }
        authResponse['policyDocument'] = policyDocument

    return authResponse