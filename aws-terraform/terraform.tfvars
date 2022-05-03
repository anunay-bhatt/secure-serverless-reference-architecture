OU_with_POST_authorization  = ["Admin1_OU", "Admin2_OU"]

/*OU_with_POST_authorization = [
    {
      client_OU = "Admin1_OU",
      issuer_CN = "Issuer1.cn.com",
      issuer_OU = "Issuer1 CA",
      authz_org = ["org1","org2","org3"]
    },
    {
      client_OU = "Admin2_OU",
      issuer_CN = "Issuer2.cn.com",
      issuer_OU = "Issuer2 CA",
      authz_org = ["org4","org5","org6","org7","org8","org9"]
    },
]*/

/*OU_with_GET_authorization = [
    {
      client_OU = "Client1_OU",
      issuer_CN = "Issuer1.cn.com",
      issuer_OU = "Issuer1 CA",
      authz_org = ["org1","org2","org3"]
    },
    {
      client_OU = "Client2_OU",
      issuer_CN = "Issuer2.cn.com",
      issuer_OU = "Issuer2 CA",
      authz_org = ["org4","org5","org6","org7","org8","org9"]
    },
]*/

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

source_ip_address = "67.188.92.120/32"

stage_name = "test"

domain_name = "ab-lumos.link"

domain_prefix = "serverless"