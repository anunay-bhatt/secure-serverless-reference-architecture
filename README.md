# Reference Architecture for a secure Serverless Application

[Related Medium Article - A secure reference design for a serverless application](TBD)

Serverless computing can help organizations reduce the operational overhead while delivering highly scalable and reliable services to the customers in a cost effective manner. But does using these serverless services also reduce the burden of security implementation? Simple answer is yes, since there is no server for the customers to manage, the security responsibilities that come with it are naturally reduced. As the cartoon illustrates, Serverless does not mean no servers. It means no responsibility for you to manage the servers yourself as your cloud provider would do the heavy lifting for you. 

Then why really bother with this article about serverless security when it's majorly taken care of by the cloud provider. One obvious reason is that not everything is managed by your provider, you as a customer still have some security responsibilities. And second, using analogy, just because you have bought a yearly pest control treatment for your house, it does not mean that you would leave food all over the place, right? Meaning you would still need to follow security practices to reduce risk on your system. This article is just about that - helping you reduce your risk for a serverless application. 

I will take the example of a demo serverless application and walk through what controls I have put in place to reduce the risk in it and what options you should be aware of as you are building your own serverless application.

## Demo Application

I have created a demo serverless application to use as reference for this article - demo vulnerability management system app which securely exposes REST APIs with AWS services- API Gateway, Lambda, DynamoDB and S3. The example code is for AWS but the same concepts can be extended to any other public cloud environment.

In this simple example, a serverless application processes, stores and serves vulnerability data to its customers:
- Vulnerability scanner services like Nessus send a POST request with vulnerability data to the Route53 domain name which aliases to the API Gateway custom domain name
- API Gateway triggers POST Lambda function which processes and stores the data into DynamoDB
- Customers of the vulnerability data send a GET request with their org id as parameter to the Route53 domain name
- API Gateway triggers GET Lambda function which fetches the data for that org id from DynamoDB table and returns to the customer 

![](https://github.com/ab-lumos/secure-serverless-reference-architecture/blob/master/Application_Architecture_sample_serverless_app.jpeg)

## Integrated Security Controls
This table provides a summary of the various security controls integrated with this sample application. For a detailed description of these, refer to the Medium article - [A secure reference design for a serverless application](TBD)

<table>
    <thead>
        <tr>
            <th>Security Area</th>
            <th>Control#</th>
            <th>Security Control</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=1 >Authentication</td>
            <td>IAM 1.1</td> <td>In the demo application, authentication is enabled via digital certificates using mutual TLS (mTLS). A root CA certificate is configured as part of API Gateway in order to authenticate client certificates.</td>
        </tr>
        <tr>
            <td rowspan=1 text-align=center>Authorization</td>
            <td>IAM 1.2 </td> <td>In the demo app, after mTLS authentication is successful, authorization happens via Lambda functions that validate if the OU (Organization Unit) in the certificate is authorized to perform the specific API method on the specific resource. This mapping is made accessible to the Lambda function via a DynamoDB table.</td>
        </tr>
        <tr>
            <td rowspan=1>Least Privilege</td>
            <td>IAM 1.3 </td> <td>Serverless cloud resources have the least amount of permissions to perform their task and no more. Ergo, in cases of unwanted abuse of these resources, the blast radius is minimal. Some examples - 1)Serverless cloud resources have the least amount of permissions to perform their task and no more. Ergo, in cases of unwanted abuse of these resources, the blast radius is minimal. 2) The AWS IAM role for the Lambda function to respond to the GET API only has permissions - "dynamodb:GetItem" and "dynamodb:Query" on the specific DyanamoDB table</td>
        </tr>
        <tr>
            <td rowspan=5>Network Security</td>
            <td>NS 1.1 </td> <td>In the demo application, the endpoint is public but it is restricted to be only accessed from my laptop ip address using resource policy on the API Gateway</td>
        </tr>
        <tr>
            <td>NS 1.2 </td> <td>Encryption in transit with TLS is enabled on the API endpoint and only secure TLS protocol and cipher version is used</td>
        </tr> 
        <tr>
            <td>NS 1.3 </td> <td>The default API endpoint is disabled so that the mTLS controls on the custom domain are not bypassed by using the default domain</td>
        </tr> 
        <tr>
            <td>NS 1.4 </td> <td>Serverless cloud backend resources are not directly accessible by public urls or public cloud accounts. Cloud configuration mistakes like making a S3 bucket public can inadvertently expose the backend data of serverless apps</td>
        </tr> 
         <tr>
            <td>NS 1.5 </td> <td>For inter-communication between services, if not configured otherwise, the traffic is routed via public Internet, which seems like an unnecessary risk as these services, in most probability, are internal to your design. In such cases and as applicable with each cloud provider, it is advisable to use private endpoints so that traffic to serverless services be kept on cloud service provider's backbone network rather than Internet at large. Endpoint policy is setup to only allow network access to a specific resource via the private endpoint</td>
        </tr> 
        <tr>
            <td rowspan=5>Code Security Hygiene</td>
            <td>CSH 1.1 </td> <td>Input is the most dangerous component of any code from a security perspective as each input field is a potential security vector that an attacker can leverage, and so care is taken before ingesting, processing or forwarding it to any third-party</td>
        </tr>
         <tr>
            <td>CSH 1.2 </td> <td>API endpoints have API throttling limits so that the API is not overwhelmed with too many requests and does not become non-functional in the event of a denial of service attack</td>
        </tr> 
         <tr>
            <td>CSH 1.3 </td> <td>API endpoints have proper error handling with a duo objective - to store details logs internally for debugging by admins and to not reveal internal design/application details in the output to the customer. Also, it's common sense, but execution of the program stops when an error occurs</td>
        </tr> 
         <tr>
            <td>CSH 1.4 </td> <td>Even Serverless applications are susceptible to database injection attacks and care is taken while implementing the queries that are run against the serverless databases like DynamoDB</td>
        </tr> 
         <tr>
            <td>CSH 1.5 </td> <td>Lambda function code must be treated like any other code in the organization i.e. it must be built via organizational CICD pipelines that have integrated static code analysis, dynamic analysis and third-party vulnerability scanning (e.g. using Snyk)</td>
        </tr> 
         <tr>
            <td rowspan=3>Data Protection</td>
            <td>DP 1.1 </td> <td>In order to prevent exposure of data stored on the public cloud via physical access to disks, all data stored on public cloud is encrypted with a secure symmetric algorithm like AES-256. Depending on the degree of security compliance required, data is either encrypted by customer supplied key (CSEK), or customer managed key (CMEK) or cloud provider managed key. The options you have also depends on the type of cloud service you are interacting with.</td>
        </tr>
            <td>DP 1.2 </td> <td>For customer-management of the cloud provider encryption key, be mindful of the following taking the examples of AWS KMS service: 1) In the demo app, for the centralized management of key access policies, AWS IAM is enabled to help control access of the CMK. This is done by assigning key permissions to the root AWS user - arn:aws:iam::${aws:PrincipalAccount}:root}. Assigning kms:* to the above AWS user is "not secure" as it allows any IAM role in the same account with proper IAM permissions to perform sensitive key admin activities. Therefore KMS policy specifically DENIES sensitive privileges like key deletion and only allows these sensitive actions to be done by select few IAM roles 2) Automatic key rotation is enabled for the CMK based on the organizational key rotation policy</td>
        </tr>
        </tr>
            <td>DP 1.3 </td> <td>Data stored on cloud which is critical to the functioning of the organization and its customers is backed up for time period (RTO and RPO) as defined in the organizational policy. The backup snapshots are also copied to a different geographical region to plan for cloud provider region outages **NOT CURRENTLY ENABLED ON THIS REPO**</td>
        </tr>
         <tr>
            <td rowspan=5>Logging</td>
            <td>LO 1.1 </td> <td>Authentication and Authorization logs are stored by the Lambda function in CloudWatch and include details like user id, timestamp, resource, access failure reason, etc. that can help in forensic investigation later</td>
        </tr>
         <tr>
            <td>LO 1.2 </td> <td>Cloud provider activity logs which provide details on who ran which api on what resources are stored in S3 bucket. These logs are useful for forensic investigations to create an event sequence. CloudTrail is enabled with specific data events from Lambda, S3 and DynamoDB. API Gateway logs are also enabled to log all API activities</td>
        </tr>
         <tr>
            <td>LO 1.3 </td> <td>Networking logs provide ingress/egress ip address, port and protocol which can be used to track lateral movement from a particular compromised host. These are enabled via VPC flow logs in AWS</td>
        </tr>
         <tr>
            <td>LO 1.4 </td> <td>All the logs stored are retained as per your organizational data retention policy based on regulatory compliance. Therefore its easier to store all logs in a central location like S3 and enforce retention and backup standards on this single location **NOT CURRENTLY ENABLED ON THIS REPO**</td>
        </tr>
         <tr>
            <td>LO 1.5 </td> <td>Preventative IAM policies explicitly deny the deletion of any of these log files. In AWS, you can do this by creating SCP to prevent users from deleting a particular S3 bucket, cloudwatch log or Glacier vault. You may also do this by creating Permission boundaries around IAM roles **NOT CURRENTLY ENABLED ON THIS REPO**</td>
        </tr>

    </tbody>
</table>

## How to deploy this code in your own environment

### Pre-requisites

1. An AWS account and privileges to deploy the related infrastructure as part of this repo

2. A Route53 domain name created in the same AWS account which will be used as the main url for the serverless service

### Deployment Steps

1. The API Gateway has mTLS enabled which means clients would need to present their certifcate which would be authentictaed by the server with a trust bundle. For the puposes of this demo, we would create self-signed certificates for CA, POST Client and GET client.

In your local system, create the following directory structure

        DOMAIN_NAME="your_domain_name"
        TMP_DIR="$HOME/tmp"
        mkdir $TMP_DIR
        mkdir $TMP_DIR/ca
        mkdir $TMP_DIR/client1
        mkdir $TMP_DIR/client2

Setting up the local Certificate Authority:

        openssl genrsa -aes256 -out $TMP_DIR/ca/ca.key 4096 chmod 400 $TMP_DIR/ca/ca.key
            <Enter passphrase>
        openssl req -new -x509 -sha256 -days 730 -key $TMP_DIR/ca/ca.key -out $TMP_DIR/ca/ca.crt
            <Enter previous passphrase>
            <Enter following details for CA cert = Country, State, City, ON, OU, CN, Email>
        chmod 444 $TMP_DIR/ca/ca.crt

Setting Client1 which will be used to make GET requests to the serverless application: 

        openssl genrsa -out $TMP_DIR/client1/client1.key 2048

"Make sure that you put an apporpriate OU in the below CSR. This OU would be used for authorization of the client. You will update the same in the terraform.tfvars file variable -- OU_with_POST_authorization"

        openssl req -new -key $TMP_DIR/client1/client1.key -out $TMP_DIR/client1/client1.csr
            <Enter following details for the cert = Country, State, City, ON, OU, CN, Email>
        openssl x509 -req -days 365 -sha256 -in $TMP_DIR/client1/client1.csr -CA $TMP_DIR/ca/ca.crt -CAkey $TMP_DIR/ca/ca.key -set_serial 2 -out $TMP_DIR/client1/client1.crt
            <Enter previous passphrase, the one used for CA>

Setting Client2 which will be used to make GET requests to the serverless application: 

        openssl genrsa -out $TMP_DIR/client2/client2.key 2048

"Make sure that you put an apporpriate OU in the below CSR. This OU would be used for authorization of the client. You will update the same in the terraform.tfvars file variable -- OU_with_GET_authorization"

        openssl req -new -key $TMP_DIR/client2/client2.key -out $TMP_DIR/client2/client2.csr
            <Enter following details for the cert = Country, State, City, ON, OU, CN, Email>
        openssl x509 -req -days 365 -sha256 -in $TMP_DIR/client2/client2.csr -CA $TMP_DIR/ca/ca.crt -CAkey $TMP_DIR/ca/ca.key -set_serial 2 -out $TMP_DIR/client2/client2.crt
            <Enter previous passphrase, the one used for CA>

Confirm that you see the 3 certificates for CA, Client1 and Client2 with appropriate details: 

        openssl x509 -in $TMP_DIR/ca/ca.crt -text -noout | grep Subject
            <This will be your trust bundle that would be handed over to API Gateway for mTLS authentication of requests>
        openssl x509 -in $TMP_DIR/client1/client1.crt -text -noout | grep Subject
            <This will be the client used for making POST requests>
        openssl x509 -in $TMP_DIR/client2/client2.crt -text -noout | grep Subject
            <This will be the client used for making GET requests>

2. Upload your trust bundle which is the public certificate for the CA to this git repo at "./aws-terraform/truststore/ca.pem"

        cp $TMP_DIR/ca/ca.crt ./aws-terraform/truststore/ca.pem

3. Update terraform variable - "OU_with_POST_authorization" with the OU name of the certificate that will be used for maing POST request to the serverless application --> make changes in the ./aws-terraform/terraform.tfvars file

4. Update terraform variable - "OU_with_GET_authorization" with the OU name of the certificate that will be used for maing GET request to the serverless application and the specific orgs to which the access would be provided  --> make changes in the ./aws-terraform/terraform.tfvars file. By default, six orgs which demo data are created as part of this module. 

5. Update the IP address of your machine in the variable "source_ip_address" at ./aws-terraform/terraform.tfvars file

        curl ipecho.net/plain

6. Update your domain name in the variable "domain_name" at ./aws-terraform/terraform.tfvars file
The Terraform code would create a new ACM cert with this domain to be used by API Gateway as the server certificate. Route53 domain record would be updated to include an alias for this domain with the API Gateway endpoint. 

7. If you have made any custom changes to any Lambda function code, make sure you update the respective zip file with the updated Lambda code

        zip -g my-deployment-package.zip lambda_function.py

7. Terraform plan and apply
This Terraform is tested with v1.1.7

        cd ./aws-terraform/
        terraform --version
        export AWS_ACCESS_KEY_ID="your_AWS_ACCESS_ID"
        export AWS_SECRET_ACCESS_KEY="your_AWS_SECRET_KEY"
        export AWS_SESSION_TOKEN="your_AWS_SESSION_TOKEN"
        export AWS_REGION="us-west-2"
        terraform init
        terraform plan
        terraform apply

Note that the first apply would result in a failure with the error - "Error creating API Gateway Domain Name: BadRequestException: The provided certificate is not in state ISSUED". This is expected since ACM changes can sometimes display eventual consistency issues with other AWS services during certificate creation/deletion, so the API Gateway service may not be able to see the new ACM certificate immediately after its created. For details on this issue - [Can not create aws_api_gateway_domain_name on the first run]<https://github.com/hashicorp/terraform-provider-aws/issues/10447>

### Deployment Outputs
 
Terraform would output the default endpoint created by API Gateway but this endpoint is disabled as part of secure by default configuration since it can bypass mTLS controls. You will be reaching to the API with the custom domain name which you supplied as input to the Terraform. See the next section on testing. 

### Post deployment testing instructions

1. Create a new self-signed certificate signed by a different CA to test if mTLS authentication works. 

        mkdir $TMP_DIR/ca2
        mkdir $TMP_DIR/client3
        openssl genrsa -aes256 -out $TMP_DIR/ca2/ca2.key 4096 chmod 400 $TMP_DIR/ca2/ca2.key
            <Enter passphrase>
        openssl req -new -x509 -sha256 -days 730 -key $TMP_DIR/ca2/ca2.key -out $TMP_DIR/ca2/ca2.crt
            <Enter previous passphrase>
            <Enter following details for CA cert = Country, State, City, ON, OU, CN, Email>
        chmod 444 $TMP_DIR/ca2/ca2.crt
        openssl genrsa -out $TMP_DIR/client3/client3.key 2048
        openssl req -new -key $TMP_DIR/client3/client3.key -out $TMP_DIR/client3/client3.csr
            <Enter following details for the cert = Country, State, City, ON, OU, CN, Email>
        openssl x509 -req -days 365 -sha256 -in $TMP_DIR/client3/client3.csr -CA $TMP_DIR/ca2/ca2.crt -CAkey $TMP_DIR/ca2/ca2.key -set_serial 2 -out $TMP_DIR/client3/client3.crt
            <Enter previous passphrase, the one used for CA>
        openssl x509 -in $TMP_DIR/client3/client3.crt -text -noout | grep Subject

Make GET request with the above cert

        curl -v -X GET --cert $TMP_DIR/client3/client3.crt --key $TMP_DIR/client3/client3.key "https://serverless."$DOMAIN_NAME"/vuln?org=org1"

{"message":"Forbidden"}

2. Test with intermediate cert

        mkdir $TMP_DIR/client6
        openssl genrsa -out $TMP_DIR/client6/client6.key 2048
        openssl req -new -key $TMP_DIR/client6/client6.key -out $TMP_DIR/client6/client6.csr
        openssl x509 -req -days 365 -sha256 -in $TMP_DIR/client6/client6.csr -CA $TMP_DIR/client1/client1.crt -CAkey $TMP_DIR/client1/client1.key -set_serial 2 -out $TMP_DIR/client6/client6.crt
        openssl x509 -in $TMP_DIR/client6/client6.crt -text -noout | grep Subject
        openssl x509 -in $TMP_DIR/client6/client6.crt -text -noout | grep Issuer

2. Using the Client1 certificate, you will be successfull with the following curl request: 

        curl -v -X POST --cert $TMP_DIR/client1/client1.crt --key $TMP_DIR/client1/client1.key "https://serverless."$DOMAIN_NAME"/vuln" --header "Content-Type: application/json" --data '{
                "VulnID" : "testID3",
                "Org" : "org1",
                "AssetName" : "lax-psg-g.internal.org.com",
                "DueDate"   : "09-09-2022",
                "PluginId"  : 23234,
                "PluginName" : "Palo Alto confusion ADE-OS Local File Inclusion",
                "Priority"  : "234234234"
        }'

{"statusCode": 200, "message": "Post vulnerability succeeded"}

3. If you try to use the above POST request with the Client2 certificate, you will receive an access error: 

        curl -v -X POST --cert $TMP_DIR/client2/client2.crt --key $TMP_DIR/client2/client2.key "https://serverless."$DOMAIN_NAME"/vuln" --header "Content-Type: application/json" --data '{
                "VulnID" : "testID3",
                "Org" : "org1",
                "AssetName" : "lax-psg-g.internal.org.com",
                "DueDate"   : "09-09-2022",
                "PluginId"  : 23234,
                "PluginName" : "Palo Alto confusion ADE-OS Local File Inclusion",
                "Priority"  : "234234234"
        }'

{"Message":"User is not authorized to access this resource with an explicit deny"}

4. If you use the GET curl command for fetching details for org1 with the Client2 certificate, you will see the vulnerability details for org1: 

        curl -v -X GET --cert $TMP_DIR/client2/client2.crt --key $TMP_DIR/client2/client2.key "https://serverless."$DOMAIN_NAME"/vuln?org=org1"

"{\"org1\": [{\"Org\": {\"S\": \"org1\"}, \"Priority\": {\"S\": \"P2\"}, \"AssetName\": {\"S\": \"lax3-org-g.internal.org.com\"}, \"VulnID\": {\"S\": \"2b5f5331-1701-105a-0cce-e17058c5c221\"}, \"PluginId\": {\"N\": \"15446\"}, \"PluginName\": {\"S\": \"Cisco ADE-OS Local File Inclusion (cisco-sa-ade-xcvAQEOZ)\"}, \"DueDate\": {\"S\": \"05-06-2022\"}}, {\"Org\": {\"S\": \"org1\"}, \"Priority\": {\"S\": \"234234234\"}, \"AssetName\": {\"S\": \"lax-psg-g.internal.org.com\"}, \"VulnID\": {\"S\": \"testID3\"}, \"PluginId\": {\"N\": \"23234\"}, \"PluginName\": {\"S\": \"Palo Alto confusion ADE-OS Local File Inclusion\"}, \"DueDate\": {\"S\": \"09-09-2022\"}}]}"

5. If you use the GET curl command for fetching details for org4 with the Client2 certificate, you will see an authorization error:

        curl -v -X GET --cert $TMP_DIR/client2/client2.crt --key $TMP_DIR/client2/client2.key "https://serverless."$DOMAIN_NAME"/vuln?org=org5"

{"Message":"User is not authorized to access this resource with an explicit deny"}
