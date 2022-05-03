import boto3
from botocore.exceptions import ClientError
import os
import json

backend_table_name = os.environ.get('BACKEND_TABLE_NAME')

def lambda_handler(event, context):
    
    print("Received following event:{}".format(event))

    input_dict = {
        "VulnID" : "",
        "Org" : "", 
        "AssetName": "",
        "DueDate": "",
        "PluginId": "", 
        "PluginName": "",
        "Priority": ""
    }

    for input in input_dict:
        if (input in event["body-json"]):
            input_dict[input] = event["body-json"][input]
        
        else:
            print("Input not received: {}".format(input))
            response = {
                "statusCode": 400,
                "message": "Invalid request body. missing below input",
                "input": input
            }
            # Encoding the json before sending to prevent against JSON injection attacks downstream
            return json.dumps(response)
        
    value = post_vuln(input_dict)
    if 'ResponseMetadata' in value:
        if 'HTTPStatusCode' in value['ResponseMetadata']:
            if value['ResponseMetadata']['HTTPStatusCode'] == 200:
                print("Put org vulnerabilities succeeded:")
                return {
                    "statusCode": 200,
                    "message": "Post vulnerability succeeded",
                }
    else:
        print("Unable to put item to the backend due to server error")
        return value
        
def post_vuln(input_dict):
    
    dynamodb = boto3.resource('dynamodb',region_name='us-west-2')
        
    table = dynamodb.Table(backend_table_name)
    
    try:
        response = table.put_item(
            Item={
                list(input_dict.keys())[0] : list(input_dict.values())[0], 
                list(input_dict.keys())[1] : list(input_dict.values())[1], 
                list(input_dict.keys())[2] : list(input_dict.values())[2], 
                list(input_dict.keys())[3] : list(input_dict.values())[3], 
                list(input_dict.keys())[4] : list(input_dict.values())[4], 
                list(input_dict.keys())[5] : list(input_dict.values())[5],
                list(input_dict.keys())[6] : list(input_dict.values())[6], 
            },
            ConditionExpression='attribute_not_exists(VulnID)'
        )
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException as e: 
        return {
            "statusCode": 500,
            "message": "Provide unique names for the Vuln ID input",
        }        
    else:
        return response