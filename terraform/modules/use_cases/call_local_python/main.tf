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
data "external" "call_http" {
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
  value = data.external.call_http.result
}

