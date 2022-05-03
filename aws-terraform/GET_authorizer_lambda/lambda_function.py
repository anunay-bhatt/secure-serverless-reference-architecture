import json
import boto3
from botocore.exceptions import ClientError
import os
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

authorizer_table_name = os.environ.get('GET_AUTHORIZER_TABLE_NAME')

def lambda_handler(event, context):

    if 'methodArn' not in event:
        logger.error("could not find 'methodArn' key in event")
        return generate_policy(client, 'Deny', '')

    client = get_OU(event)
    if (client == ""):
        return generate_policy('null', 'Deny', event['methodArn'])

    requested_org = get_queryStringParameters(event)
    if (requested_org == ""):
        print("Org input not received")
        return generate_policy(client, 'Deny', event['methodArn'])

    # Since this is a demo deployment, I am not verifying the Issuer of the client certificate
    # For Production systems, Issuer OU and CN need to be verified before validating the client subject OU      
    print("Checking if Client: {} is authorized to access Org: {}".format(client,requested_org))
    authorized_org = get_authorized_orgs(client)
    if(requested_org in authorized_org):
        logger.info("Authorization successful for client:{}".format(event['requestContext']['identity']))
        return generate_policy(client, 'Allow', event['methodArn'])
    else:
        logger.error("Authorization denied for client:{}".format(event['requestContext']['identity']))
        return generate_policy(client, 'Deny', event['methodArn'])
        
def get_OU(event):
    OU = ""
    subjectDN = event['requestContext']['identity']['clientCert']['subjectDN']
    for item in subjectDN.split(","):
        if(item.find("OU") == 0):
            OU = item.split("=")[1]
    return OU    

def get_queryStringParameters(event):
    queryStringParameter = ""
    for param in event['queryStringParameters']:
        if(param == "org"):
            queryStringParameter = event['queryStringParameters']["org"]
            return queryStringParameter

def check(client):
    
    dynamodb = boto3.resource('dynamodb',region_name='us-west-2')
    table = dynamodb.Table(authorizer_table_name)
    try:
        response = table.get_item(Key={'Client': client})
        if('Item' in response):
            return response['Item']['Org']
    except ClientError as e:
        logger.error("Details of server error:",e.response['Error']['Message'])

def get_authorized_orgs(client):
    
    dynamodb = boto3.resource('dynamodb',region_name='us-west-2')
    table = dynamodb.Table(authorizer_table_name)
    try:
        response = table.get_item(Key={'Client': client})
        if('Item' in response):
            return response['Item']['Org']
    except ClientError as e:
        logger.error("Details of server error:",e.response['Error']['Message'])

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
            