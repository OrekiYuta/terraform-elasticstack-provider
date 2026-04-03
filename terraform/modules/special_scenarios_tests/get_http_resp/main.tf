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
  # url = "https://httpbin.org/get"
  # url = "https://ipinfo.io/json"
  url = "https://whois.pconline.com.cn/ipJson.jsp?json=tru"

  request_headers = {
    Accept = "application/json"
  }
}

output "get_http_resp" {
  value = jsondecode(data.http.response.response_body)
}


# $ (venv) terraform plan -target "module.get_http_resp"
# module.get_http_resp.data.http.example: Reading...
# module.get_http_resp.data.http.example: Still reading... [00m10s elapsed]
# module.get_http_resp.data.http.example: Read complete after 15s [id=https://httpbin.org/get]
#
# Changes to Outputs:
#   + get_http_resp = {
#       + get_http_resp = {
#           + args    = {}
#           + headers = {
#               + Accept          = "application/json"
#               + Accept-Encoding = "gzip"
#               + Host            = "httpbin.org"
#               + User-Agent      = "Go-http-client/2.0"
#               + X-Amzn-Trace-Id = "Root=1-69cf3e23-04ce1d8e3da32cf1478d6896"
#             }
#           + origin  = "163.125.218.185"
#           + url     = "https://httpbin.org/get"
#         }
#     }
#
# You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.
