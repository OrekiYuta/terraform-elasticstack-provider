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

locals {
  json_payload = jsonencode(var.payload)
}

output "command_resp" {
  value = data.external.call_http.result
}

# for macos
data "external" "call_http" {
  program = ["bash", "-c", <<EOT
response=$(curl -s -X POST ${var.api_url} \
  -H "Content-Type: application/json" \
  -d '${local.json_payload}')
echo "{\"result\": $(echo \"$response\" | jq -Rs .)}"
EOT
  ]
}

# (.venv) terraform % terraform plan -target "module.use_cases_call_local_command"
# module.use_cases_call_local_command.data.external.call_http: Reading...
# module.use_cases_call_local_command.data.external.call_http: Read complete after 2s [id=-]
#
# Changes to Outputs:
#   + use_case_call_local_command = {
#       + command_resp = {
#           + result = <<-EOT
#                 "{ "args": {}, "data": "{\"env\":\"dev\",\"name\":\"terraform\"}", "files": {}, "form": {}, "headers": { "Accept": "*/*", "Content-Length": "32", "Content-Type": "application/json", "Host": "httpbin.org", "User-Agent": "curl/8.7.1", "X-Amzn-Trace-Id": "Root=1-69dc4c52-0c5ec24868e5c85e667d980c" }, "json": { "env": "dev", "name": "terraform" }, "origin": "106.38.0.82", "url": "https://httpbin.org/post" }"
#             EOT
#         }
#     }

# for windows
# data "external" "call_http" {
#   program = ["powershell", "-Command", <<EOT
# $response = Invoke-RestMethod -Method Post -Uri '${var.api_url}' -Body '${local.json_payload}' -ContentType 'application/json'
# $result = @{ result = ($response | ConvertTo-Json -Compress -Depth 10) }
# $result | ConvertTo-Json -Compress
# EOT
#   ]
# }

# ======================== windows output ========================
# $ (venv) terraform plan -target "module.call_local_command"
# module.call_local_command.data.external.call_http: Reading...
# module.call_local_command.data.external.call_http: Read complete after 5s [id=-]
#
# Changes to Outputs:
#   + call_local_command = {
#       + command_resp = {
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
#                       + Content-Length  = "32"
#                       + Content-Type    = "application/json"
#                       + Host            = "httpbin.org"
#                       + User-Agent      = "Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.17763.2268"
#                       + X-Amzn-Trace-Id = "Root=1-69cf464e-5b6e91506227a58b07ac8feb"
#                     }
#                   + json    = {
#                       + env  = "dev"
#                       + name = "terraform"
#                     }
#                   + origin  = "142.171.121.243"
#                   + url     = "https://httpbin.org/post"
#                 }
#             )
#         }
#     }
#
# You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.
