terraform {
  required_version = ">= 1.0"
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.14"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
