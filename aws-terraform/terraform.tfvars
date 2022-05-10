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

#example source_ip_address = "2.3.2.4/32"
source_ip_address = ""

stage_name = "test"

#example domain_name = "google.com"
domain_name = ""

domain_prefix = "serverless"