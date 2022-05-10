import json
import boto3
from botocore.exceptions import ClientError
import os
from datetime import datetime

authorizer_table_name = os.environ.get('GET_AUTHORIZER_TABLE_NAME')

class Logger(object):
    """Print out authorization logging to Cloudwatch"""
    def __init__(self, event, context, debug_message="", failure_reason="None", status="failure", user_id=""):
        self.event = event
        self.context = context
        self.debug_message = debug_message
        self.failure_reason = failure_reason
        self.status = status
        self.user_id = event['requestContext']['identity']['clientCert']['subjectDN']

    def json_log(self):
        return {
            "failureReason": self.failure_reason,
            "logRecordType": "authorization",
            "sourceIp": self.event["requestContext"]["identity"]["sourceIp"],
            "status": self.status,
            "timestamp": int(datetime.utcnow().timestamp()),
            "userAgent": self.event["requestContext"]["identity"]["userAgent"],
            "userId": self.user_id,
            "action": self.event["httpMethod"],
            "queryStringParameters": self.event["queryStringParameters"],
            "path": self.event["path"],
            "resourceId": self.event['requestContext']['resourceId'],
            "apiId": self.event['requestContext']['apiId'],
            "stage": self.event['requestContext']['stage']
        }

def lambda_handler(event, context):
    l = Logger(event, context)
    if 'methodArn' not in event:
        l.failure_reason = "could not find 'methodArn' key in event"
        print(l.json_log())
        return generate_policy(None, 'Deny', '')

    client = get_OU(event)
    if (client == ""):
        l.failure_reason = "could not find OU in client certificate"
        print(l.json_log())
        return generate_policy(None, 'Deny', event['methodArn'])

    requested_org = get_queryStringParameters(event)
    if (requested_org == ""):
        l.failure_reason = "Org input not received"
        print(l.json_log())
        return generate_policy(client, 'Deny', event['methodArn'])
    
    print("Checking if Client: {} is authorized to access Org: {}".format(client,requested_org))
    authorized_org = get_authorized_orgs(client)
    if(requested_org in authorized_org):
        l.status="success"
        print(l.json_log())
        return generate_policy(client, 'Allow', event['methodArn'])
    else:
        l.failure_reason = "Not Authorized"
        print(l.json_log())
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

def get_authorized_orgs(client):
    
    dynamodb = boto3.resource('dynamodb',region_name='us-west-2')
    table = dynamodb.Table(authorizer_table_name)
    try:
        response = table.get_item(Key={'Client': client})
        if('Item' in response):
            return response['Item']['Org']
    except ClientError as e:
        l.failure_reason = f"Server error: {e}"
        print(l.json_log())
        return generate_policy(None, 'Deny', event['methodArn'])


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
            