variable "rgname"{
    type = string
    description = "used for naming resource group"
}

variable "location"{
    type = string
    description = "used for selecting the location"
}

variable "prefix"{
    type = string
    description = "used for all the resource"
}
    
variable "vnet_cidr_prefix" {
    type = string
    description = "this variable drfines address for vnet"
  }

  variable "subnet1_cidr_prefix" {
    type = string
    description = "this variable drfines address for subnet"
}