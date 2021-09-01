OU_with_POST_authorization  = ["Admin1_OU", "Admin2_OU"]

OU_with_GET_authorization = [
    {
      client_OU = "Client1_OU",
      org = ["org1","org2","org3"]
    },
    {
      client_OU = "Client2_OU",
      org = ["org4","org5","org6","org7","org8","org9"]
    }
  ]

source_ip_address = "13.110.54.43/32"

stage_name = "test"

domain_name = "refarch.ab-lumos.link"

domain_certificate_arn = "arn:aws:acm:us-west-2:259963121161:certificate/69f8ee0c-3a71-446f-8e83-b724d05c029a"
