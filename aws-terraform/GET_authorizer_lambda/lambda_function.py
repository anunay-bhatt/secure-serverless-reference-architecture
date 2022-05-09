import json
import boto3
from botocore.exceptions import ClientError
import os
#import logging
#logger = logging.getLogger()
#logger.setLevel(logging.INFO)

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

    def log_json(self):
        query_string_parameters = {}
        for key in self.event["params"]["querystring"]:
            query_string_parameters[key] = self.event["params"]["querystring"][key]
        path_parameters = {}
        for key in self.event["params"]["path"]:
            path_parameters[key] = self.event["params"]["path"][key]

        return {
            "failureReason": self.failure_reason,
            "logRecordType": "authorization",
            "sourceIp": self.event["context"]["source-ip"],
            "status": self.status,
            "timestamp": int(datetime.utcnow().timestamp()),
            "userAgent": self.event["context"]["user-agent"],
            "userId": self.user_id,
            "action": self.event["context"]["http-method"],
            "uri": f"{self.event['params']['header']['X-Forwarded-Proto']}://{self.event['params']['header']['Host']}:{self.event['params']['header']['X-Forwarded-Port']}{self.event['context']['resource-path']}",
            "queryStringParameters": query_string_parameters,
            "pathParameters": path_parameters,
            "apiId": self.event['context']['api-id'],
            "resourceId": self.event['context']['resource-id'],
            "stage": self.event['context']['stage']
        }

def lambda_handler(event, context):
    l = Logger(event, context)
    if 'methodArn' not in event:
        l.failure_reason = "could not find 'methodArn' key in event"
        print(l.json_log())
        #logger.error("could not find 'methodArn' key in event")
        return generate_policy(None, 'Deny', '')

    client = get_OU(event)
    if (client == ""):
        l.failure_reason = "could not find OU in client certificate"
        print(l.json_log())
        return generate_policy(None, 'Deny', event['methodArn'])

    requested_org = get_queryStringParameters(event)
    if (requested_org == ""):
        #print("Org input not received")
        l.failure_reason = "Org input not received"
        print(l.json_log())
        return generate_policy(client, 'Deny', event['methodArn'])

    # Since this is a demo deployment, I am not verifying the Issuer of the client certificate
    # For Production systems, Issuer OU and CN need to be verified before validating the client subject OU      
    print("Checking if Client: {} is authorized to access Org: {}".format(client,requested_org))
    authorized_org = get_authorized_orgs(client)
    if(requested_org in authorized_org):
        #logger.info("Authorization successful for client:{}".format(event['requestContext']['identity']))
        l.status="success"
        print(l.json_log())
        return generate_policy(client, 'Allow', event['methodArn'])
    else:
        #logger.error("Authorization denied for client:{}".format(event['requestContext']['identity']))
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

#def check(client):
#    
#    dynamodb = boto3.resource('dynamodb',region_name='us-west-2')
#    table = dynamodb.Table(authorizer_table_name)
#    try:
#        response = table.get_item(Key={'Client': client})
#        if('Item' in response):
#            return response['Item']['Org']
#    except ClientError as e:
#        logger.error("Details of server error:",e.response['Error']['Message'])

def get_authorized_orgs(client):
    
    dynamodb = boto3.resource('dynamodb',region_name='us-west-2')
    table = dynamodb.Table(authorizer_table_name)
    try:
        response = table.get_item(Key={'Client': client})
        if('Item' in response):
            return response['Item']['Org']
    except ClientError as e:
        #logger.error("Details of server error:",e.response['Error']['Message'])
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
            