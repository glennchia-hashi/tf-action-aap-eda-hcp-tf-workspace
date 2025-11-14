variable "ssh_aap_ip" {
  description = "The IP Address of the AAP instance to allowlist for SSH to the EC2 instance"
  type        = string
}

variable "http_allowed_ip" {
  description = "The IP Address to allowlist for HTTP to the EC2 instance to verify the nginx installation"
  type        = string
}

variable "region" {
  description = "Region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "tf_aap_resource_prefix" {
  description = "Prefix for TF AAP AWS resources created"
  type        = string
  default     = "tf-aap"
}

variable "ssh_username" {
  description = "ssh username for the user created in the target EC2 instance"
  type        = string
}

variable "ssh_password" {
  description = "ssh password for the user created in the target EC2 instance"
  type        = string
  sensitive   = true
}

variable "aap_event_stream_username" {
  description = "Event stream username configured on AAP"
  type        = string
}

variable "aap_event_stream_password" {
  description = "Event stream password configured on AAP"
  type        = string
  sensitive   = true
}

variable "aap_inventory_name" {
  description = "Inventory name for host to register itself to"
  type        = string
  default     = "tf_aap_demo"
}

variable "aap_event_stream_name" {
  description = "Event stream name for datasource to lookup event stream URL"
  type        = string
  default     = "HCP TF Actions"
}

variable "aap_job_template_name" {
  description = "Job template name to run on host"
  type        = string
  default     = "Install Nginx Job Template"
}
