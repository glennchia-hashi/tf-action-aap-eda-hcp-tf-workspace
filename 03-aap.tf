locals {
  organization_name = "Default"
}

data "aap_inventory" "this" {
  name              = var.aap_inventory_name
  organization_name = local.organization_name
}

resource "aap_group" "this" {
  inventory_id = aap_inventory.this.id
  name         = "demo"
}

resource "aap_host" "this" {
  inventory_id = data.aap_inventory.this.id
  name         = "tf-actions-demo-host"
  description  = "Virtual machine with public IP ${aws_instance.tf_aap.public_ip}"

  variables = jsonencode({
    ansible_host = aws_instance.tf_aap.public_ip
  })

  groups = [aap_group.this.id]
}

data "aap_eda_eventstream" "this" {
  name = var.aap_event_stream_name
}

action "aap_eda_eventstream_post" "create" {
  config {
    limit             = aap_group.this.name
    template_type     = "job"
    job_template_name = var.aap_job_template_name
    organization_name = local.organization_name

    event_stream_config = {
      username = var.aap_event_stream_username
      password = var.aap_event_stream_password
      url      = data.aap_eda_eventstream.this.url
    }
  }
}
