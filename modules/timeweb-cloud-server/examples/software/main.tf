module "cloud_server" {
  for_each = var.servers

  source = "../../"

  name               = each.key
  location           = each.value.location
  availability_zone  = each.value.availability_zone
  software           = each.value.software
  create_floating_ip = each.value.create_floating_ip
  preset             = each.value.preset
}
