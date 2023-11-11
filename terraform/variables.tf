variable "location" {
  type = string
  default = "eastus"
}

variable "prefix" {
  type = string
  default = "whistle"
}

variable "credentials" {
  type = object({
    app_id = string
    secret = string
    tenant_id = string
    subscription_id = string
  })
}

variable "k8s_node_count" {
  type = number
  default = 1
}
