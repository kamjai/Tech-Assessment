lines (1075 sloc)  37.5 KB

variable "project_id" {
  description = "The ID of the project where this VPC will be created"
}

variable "project_number" {
  description = "The ID of the project where this VPC will be created"
}

variable "environment" {
  description = "The environment of the project where this VPC will be created"
}

variable "region" {
  description = "The region where this VPC will be created"
}

variable "zone" {
  description = "The region where this VPC will be created"
  default     = "us-east1-b"
  }

variable "zones" {
  description = "List of zones in which to create VMs and instance groups."
  type        = list(string)
}


#####################################Nginx#Proxy######################################################################################################
variable "health_check_config" {
  description = "(Optional) auto-created health check configuration, use the output self-link to set it in the auto healing policy. Refer to examples for usage."
  type = object({
    type    = string      # http https tcp ssl http2
    check   = map(any)    # actual health check block attributes
    config  = map(number) # interval, thresholds, timeout
    logging = bool
  })
  default = null
}
variable "ilb_source_tags" {
  description = "Source tags to be used for Firewall rule. Only applicable if lb_type is INTERNAL"
  type        = list(string)
  default     = []
}

variable "lb_type" {
  description = "Type of load balancer to be created. Takes values either INTERNAL or EXTERNAL"
  type        = string
  default     = "NONE"
  validation {
    condition     = contains(["INTERNAL", "EXTERNAL", "NONE"], var.lb_type)
    error_message = "Valid values for var: lb_type are (INTERNAL, EXTERNAL, NONE)."
  }
}

variable "existing_instance_template" {
  description = "Instance template self-link."
  type        = string
  default     = null
}
variable "named_ports" {
  description = "(Optional) Named ports. Protocol being the key and port number being the value. It's first entry becomes the default backend values for Load Balancer."
  type        = map(number)
  default     = null
}
variable "instance_tag" {
  description = "Instance tag to be created. This tag is used as target_tag while creating load balancers. This value is not used if 'existing_instance_template' is provided, where tags are fetched from existing_instance_template dynamically while creating the load balancer"
  type        = string
  default     = "mig-instance-default"
}
variable "lb_name_prefix" {
  description = "(Optional) Name for the forwarding rule and prefix for supporting resources. Should be non-null to create a HTTPS load balancer"
  type        = string
  default     = null
}

variable "target_tags" {
  description = "target tags to be used for Firewall rule."
  type        = list(string)
  default     = []
}
variable "number-of-vm" {
  description = "target tags to be used for nginx vm creation."
  type        = number
  default     = 2
}

variable "fh_project_roles" {
  description = "List of roles to be granted at the project level to the service account. These will be added to existing project IAM roles."
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "Machine type of NGINX MIG"
  type        = string
}

      
