terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

data "http" "response" {
  # url = "https://api.github.com/repos/hashicorp/terraform"
  url = "https://httpbin.org/get"
  # url = "https://ipinfo.io/json"
  # url = "https://whois.pconline.com.cn/ipJson.jsp?json=true"

  request_headers = {
    Accept = "application/json"
  }
}

output "call_external_http" {
  value = jsondecode(data.http.response.response_body)
}

# $ (venv) terraform plan -target "module.call_external_http"
# module.call_external_http.data.http.response: Reading...
# module.call_external_http.data.http.response: Still reading... [00m10s elapsed]
# module.call_external_http.data.http.response: Read complete after 17s [id=https://httpbin.org/get]
#
# Changes to Outputs:
#   + call_external_http = {
#       + call_external_http = {
#           + args    = {}
#           + headers = {
#               + Accept          = "application/json"
#               + Accept-Encoding = "gzip"
#               + Host            = "httpbin.org"
#               + User-Agent      = "Go-http-client/2.0"
#               + X-Amzn-Trace-Id = "Root=1-69cf4318-26cd2dd519ebe71f1eceba73"
#             }
#           + origin  = "163.125.218.185"
#           + url     = "https://httpbin.org/get"
#         }
#     }
#
# You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.
