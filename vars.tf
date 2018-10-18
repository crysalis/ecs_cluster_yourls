variable "vpc_cidr" {
	default = "10.0.0.0/16"
}

variable "db_name" {
	default = "yourls_db"
}

variable "db_user" {
	default = "yourls"
}

variable "db_pwd" {
	default = "password"
}

variable "domain" {
	default = "test.com"
}

variable "yourls_pass" {
  default = "password"
}

variable "yourls_user" {
  default = "admin"
}

variable "yourls_version" {
  default = "latest"
}
