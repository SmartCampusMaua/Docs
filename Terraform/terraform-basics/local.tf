resource "local_file" "example" {
  filename = "examplo.txt"
  content = var.content
}

data "local_file" "content-examplo" {
  filename = "examplo.txt"
}

output "data-source-result" {
  value = data.local_file.content-examplo.content_base64
}

variable "content" {
  type = string
  default = "Default Value!"
}

output "file-id" {
  value = resource.local_file.example.id
}

output "content" {
  value = var.content
}