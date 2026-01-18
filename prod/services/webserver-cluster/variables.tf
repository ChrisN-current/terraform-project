module "constants" {
  source = "../../../constants"
}

module "IAM_constants" {
  source = "../../../../../base/IAM/constants"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = "example_database_stage"
}

variable "machine_type" {
  description = "Allowed GCP machine types"
  type        = string
  
  validation {
    condition     = contains(["e2-micro", "e2-small"], var.machine_type)
    error_message = "Instance type must be one of: e2-micro, e2-small"
  }
}

variable "min_size" {
  description = "The minimum number of instances in the MIG"
  type        = number
  
  validation {
    condition     = var.min_size >= 1
    error_message = "min_size must be at least 1"
  }

  validation {
    condition     = var.min_size <= var.max_size
    error_message = "min_size can't be greater than max_size"
  }

  validation {
    condition     = var.min_size > 0
    error_message = "value must be greater than 0"
  }

  validation {
    condition     = var.min_size <= 10
    error_message = "value must be less than or equal to 10"
  }
}

