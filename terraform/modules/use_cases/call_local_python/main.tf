variable "api_url" {
  type    = string
  default = "https://httpbin.org/post"
}

variable "payload" {
  type = object({
    name = string
    env  = string
  })

  default = {
    name = "terraform"
    env  = "dev"
  }
}

# ensure python is installed and available in PATH, and the call_http.py script is present in the same directory as this main.tf
data "external" "call_python" {
  program = [
    "python",
    "${path.module}/call_http.py"
  ]

  query = {
    api_url = var.api_url
    payload = jsonencode(var.payload)
  }
}

output "python_resp" {
  value = data.external.call_python.result
}

# (.venv) terraform % terraform plan -target "module.use_cases_call_local_python"
# module.use_cases_call_local_python.data.external.call_python: Reading...
# module.use_cases_call_local_python.data.external.call_python: Read complete after 2s [id=-]
#
# Changes to Outputs:
#   + use_case_call_local_python = {
#       + python_resp = {
#           + result = jsonencode(
#                 {
#                   + args    = {}
#                   + data    = jsonencode(
#                         {
#                           + env  = "dev"
#                           + name = "terraform"
#                         }
#                     )
#                   + files   = {}
#                   + form    = {}
#                   + headers = {
#                       + Accept          = "*/*"
#                       + Accept-Encoding = "gzip, deflate, zstd"
#                       + Content-Length  = "35"
#                       + Content-Type    = "application/json"
#                       + Host            = "httpbin.org"
#                       + User-Agent      = "python-requests/2.33.1"
#                       + X-Amzn-Trace-Id = "Root=1-69dc4d07-18463cf747cba4374205a52e"
#                     }
#                   + json    = {
#                       + env  = "dev"
#                       + name = "terraform"
#                     }
#                   + origin  = "45.64.247.97"
#                   + url     = "https://httpbin.org/post"
#                 }
#             )
#         }
#     }
#
# You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.