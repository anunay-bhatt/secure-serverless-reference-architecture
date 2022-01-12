variable "platform_mandatory_tags" {
  description = "platform mandated tags to be supplied as ENV vars by spinnaker pipeline"
  type        = map(any)
  default     = {}
}

variable "OU_with_POST_authorization" {
  description = "List of OUs which have authorization to use the POST API"
  type        = list(string)
}

variable "OU_with_GET_authorization" {
  description = "Map of OUs which have authorization to use the GET API along with the orgs that they can access"
  type = list(object({
    client_OU = string
    org = list(string)
  }))
}

variable "source_ip_address" {
  description = "Use a resource policy to only allow certain IP addresses to access the API Gateway REST API"
  type =  string
}

variable "stage_name" {
  description = "Stage name for the REST API"
  type =  string
}

variable "domain_name" {
  description = "Domain name for accessing the REST API"
  type =  string
}

variable "domain_prefix" {
  description = "Prefix for domain name"
  type =  string
}


