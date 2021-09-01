# How to deploy this code in your own environment

## Pre-requisites

1. An AWS account and privileges to deploy the related infrastructure as part of this repo

2. A domain name which you own and which will be used as the main url for the VMS service. Update your domain name in the terraform.tfvars file

3. A public certificate issued by AWS Certifcate Maanger (ACM) certifcate for the above the domain name. Note that ACM would ask you for domain verification with DNS record update or email verification. Update your ACM certificate in the terraform.tfvars file 

Please note - It is possible to import your own certificate into ACM and use it as part of this solution. You will still need to create an ACM-issued cert for domain verification purposes. This cert would not be used for TLS connection. If following such approach, please update the domain.tf code to include a domain verification cert. 

<link to ACM documentation>
<link to mTLS with API gateway>

4. The API Gateway has mTLS enabled which means clients would need to present their certifcate which would be authentictaed by the server with a trust bundle. Ergo, create a self-signed certificate with openssl and provide the CA cert public key bundle in the repo - ??  

Certificate Authority:

        openssl genrsa -aes256 -out ca/ca.key 4096 chmod 400 ca/ca.key
        openssl req -new -x509 -sha256 -days 730 -key ca/ca.key -out ca/ca.crt
        chmod 444 ca/ca.crt

POST Client Certificate:
This certificat is used for creating/adding new vulnerability data to the database

        openssl genrsa -out client/client_post.key 2048

"Make sure that you put an apporpriate OU in the below CSR. This OU would be used for authorization of the client. You will update the same in the variable -- OU_with_POST_authorization"

        openssl req -new -key client/client_post.key -out client/client_post.csr
        openssl x509 -req -days 365 -sha256 -in client/client_post.csr -CA ca.crt -CAkey ca.key -set_serial 2 -out client/client_post.crt

GET Client Certificate:
This certificat is used for viewing vulnerability data from the database

        openssl genrsa -out client/client_get.key 2048

"Make sure that you put an apporpriate OU in the below CSR. This OU would be used for authorization of the client. You will update the same in the variable -- OU_with_GET_authorization"

        openssl req -new -key client/client_get.key -out client/client_get.csr
        openssl x509 -req -days 365 -sha256 -in client/client_get.csr -CA ca.crt -CAkey ca.key -set_serial 2 -out client/client_get.crt

5. Upload your trust bundle which is the public certificate for your root CA at "./trustbundle/certificates.pem"

6. Update the OU name for the certificate that will use the POST API in the variable in terraform.tfvars file --> "OU_with_POST_authorization"

7. Update the OU name for the certificate that will be used for the GET API in the variable in terraform.tfvars file --> "OU_with_GET_authorization". Please also mention the Orgs that this partcular OU will have authroization to access. 


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

1. The default endpoint created by API Gateway is disabled by deafult as it can bypass mTLS controls. In order to hit the API endpoint created by custom domain name, you will need to update your DNS records withan alias. 

An example below: 
Domain name : ""
A name : ""

Changes should be propagated in about a minute or more in some cases

2. Using the POST client certificate, you will be successfull with the following curl request: 

3. Using the POST client certificate, you will NOT be successfull with the following curl request: 

4. Using the GET client certificate, you will get response for the following curl request: 

5. Using the GET client certificate, you will NOT get response for the following curl request: 