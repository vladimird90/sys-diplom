variable "resources" {
  type = map(number)
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}

variable "user" {
  type = string
  default = "vadyakov"
}

variable "disk_size" {
  type = number
  default = 10  
}

variable "disk_type" {
  type = string
  default = "network-hdd"
}