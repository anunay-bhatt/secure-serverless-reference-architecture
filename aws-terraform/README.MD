# How to deploy this code in your own environment

## Pre-requisites

1. An AWS account and privileges to deploy the related infrastructure as part of this repo

2. A domain name which you own and which will be used as the main url for the VMS service. Update your domain name in the terraform.tfvars file

3. The API Gateway has mTLS enabled which means clients would need to present their certifcate which would be authentictaed by the server with a trust bundle. For the puposes of this demo, create self-signed certificates for CA, POST Client and GET using the below commands:

Certificate Authority:

        openssl genrsa -aes256 -out ca/ca.key 4096 chmod 400 ca/ca.key
        openssl req -new -x509 -sha256 -days 730 -key ca/ca.key -out ca/ca.crt
        chmod 444 ca/ca.crt

POST Client Certificate:
This certificat is used for creating/adding new vulnerability data to the database

        openssl genrsa -out client/client_post.key 2048

"Make sure that you put an apporpriate OU in the below CSR. This OU would be used for authorization of the client. You will update the same in the terraform.tfvars file variable -- OU_with_POST_authorization"

        openssl req -new -key client/client_post.key -out client/client_post.csr
        openssl x509 -req -days 365 -sha256 -in client/client_post.csr -CA ca.crt -CAkey ca.key -set_serial 2 -out client/client_post.crt

GET Client Certificate:
This certificat is used for viewing vulnerability data from the database

        openssl genrsa -out client/client_get.key 2048

"Make sure that you put an apporpriate OU in the below CSR. This OU would be used for authorization of the client. You will update the same in the terraform.tfvars file variable -- OU_with_GET_authorization"

        openssl req -new -key client/client_get.key -out client/client_get.csr
        openssl x509 -req -days 365 -sha256 -in client/client_get.csr -CA ca.crt -CAkey ca.key -set_serial 2 -out client/client_get.crt

4. Upload your trust bundle which is the public certificate for your root CA at "./trustbundle/ca.pem"

5. Update the OU name for the certificate that will use the POST API in the variable in terraform.tfvars file --> "OU_with_POST_authorization"

6. Update the OU name for the certificate that will be used for the GET API in the variable in terraform.tfvars file --> "OU_with_GET_authorization". Please also mention the Orgs that this partcular OU will have authorization to access. 


## Inputs
Update terraform.tfvars with your input values as necessary:

Table below: 


## Terraform apply
Plan, apply and check results

        terraform plan
        terraform apply

## Outputs
 
Table below: 

## Post deployment instructions

The default endpoint created by API Gateway is disabled as it can bypass mTLS controls. You will be reaching to the API with the custom domain name which you supplied as input to the Terraform. This Terraform code also updates the DNS record for the domain with an alias for the API Gateway endpoint.

1. Using the POST client certificate, you will be successfull with the following curl request: 
curl -v -X POST --cert ./client_post/client_post.crt --key ./client_post/client_post.key "https://serverless.<your_domain_name>/vuln" --header "Content-Type: application/json" --data '{
          "VulnID" : "testID3",
          "Org" : "org1",
          "AssetName" : "lax-psg-g.internal.org.com",
          "DueDate"   : "09-09-2022",
          "PluginId"  : 23234,
          "PluginName" : "Palo Alto confusion ADE-OS Local File Inclusion",
          "Priority"  : "234234234"
}'

2. If you try to use the above POST request with the GET client using the below command, you will receive an access error: 
curl -v -X POST --cert ./client_post/client_get.crt --key ./client_post/client_get.key "https://serverless.<your_domain_name>/vuln" --header "Content-Type: application/json" --data '{
          "VulnID" : "testID3",
          "Org" : "org1",
          "AssetName" : "lax-psg-g.internal.org.com",
          "DueDate"   : "09-09-2022",
          "PluginId"  : 23234,
          "PluginName" : "Palo Alto confusion ADE-OS Local File Inclusion",
          "Priority"  : "234234234"
}'

3. Using the GET client certificate, you will get response for the following curl request: 
curl -v -X GET --cert ./client_get/client_get.crt --key ./client_get/client_get.key "https://serverless.<your_domain_name>/vuln?org=org1"

4. Check for other orgs which are given access to the GET client, you will the access denied error: 
curl -v -X GET --cert ./client_get/client_get.crt --key ./client_get/client_get.key "https://serverless.ab-lumos.link/vuln?org=org5"