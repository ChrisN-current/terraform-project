module "constants" {
  source = "../../constants"
}

module "IAM_constants" {
  source = "../../../../base/IAM/constants"
}

variable "usernames" {
  default = ["neo.0@example.com", "neo.1@example.com", "neo.2@example.com"]
}

variable "hero_thousand_faces" {
  description = "map"
  type        = map(string)
  default     = {
    neo       = "hero"
    trinity   = "love interest"
    morpheus  = "mentor"
  }
}

variable "names" {
  description = "Names to render"
  type       = list(string)
  default    = ["neo, trinity, morpheus"]
}