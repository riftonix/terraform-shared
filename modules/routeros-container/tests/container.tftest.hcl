mock_provider "routeros" {}

variables {
  name         = "app"
  remote_image = "ghcr.io/example/app:1.0.0"
  root_dir     = "disk1/containers/app"
  network = {
    router_address    = "172.18.0.1/30"
    container_address = "172.18.0.2/30"
  }
}

run "valid_addresses_and_defaults" {
  command = plan

  assert {
    condition     = routeros_interface_veth.this.name == "veth-app"
    error_message = "The interface name must default to veth-<name>."
  }

  assert {
    condition     = routeros_interface_veth.this.address == toset(["172.18.0.2/30"])
    error_message = "The veth interface must carry the container address."
  }

  assert {
    condition     = routeros_interface_veth.this.gateway == "172.18.0.1"
    error_message = "The container gateway must be the router host address."
  }

  assert {
    condition     = routeros_ip_address.this.address == "172.18.0.1/30" && routeros_ip_address.this.interface == "veth-app"
    error_message = "The router address must be set on the veth interface."
  }

  assert {
    condition     = routeros_container.this.interface == "veth-app" && routeros_container.this.remote_image == "ghcr.io/example/app:1.0.0" && routeros_container.this.root_dir == "disk1/containers/app"
    error_message = "The container must use the veth interface, the image and the root directory."
  }

  assert {
    condition     = routeros_container.this.running == false
    error_message = "The container must not start on creation by default."
  }

  assert {
    condition     = routeros_container.this.start_on_boot == false
    error_message = "The container must not start on boot by default."
  }

  assert {
    condition     = routeros_container.this.auto_restart_interval == null
    error_message = "The container must have no restart interval by default."
  }

  assert {
    condition     = routeros_container.this.envlist == null && length(routeros_container_envs.this) == 0
    error_message = "Without envs there must be no environment list."
  }

  assert {
    condition     = routeros_container.this.devices == null
    error_message = "Without devices the attribute must stay unset."
  }

  assert {
    condition     = routeros_container.this.logging == true && routeros_container.this.check_certificate == true
    error_message = "Logging and certificate validation must be enabled by default."
  }

  assert {
    condition     = routeros_container.this.comment == "Container app" && routeros_interface_veth.this.comment == "Container app" && routeros_ip_address.this.comment == "Container app"
    error_message = "The default comment must be used on all resources."
  }

  assert {
    condition     = output.router_address == "172.18.0.1" && output.container_address == "172.18.0.2" && output.interface_name == "veth-app"
    error_message = "The address outputs must be host addresses."
  }

  assert {
    condition     = output.egress == null
    error_message = "Without egress the egress output must be null."
  }
}

run "explicit_interface_name_and_egress" {
  command = plan

  variables {
    network = {
      interface_name    = "veth-custom"
      router_address    = "172.18.0.1/30"
      container_address = "172.18.0.2/30"
    }
    egress = {
      name          = "app"
      routing_table = "via-app"
    }
    comment = "App container"
  }

  assert {
    condition     = routeros_interface_veth.this.name == "veth-custom" && routeros_container.this.interface == "veth-custom"
    error_message = "The explicit interface name must be used."
  }

  assert {
    condition = output.egress == {
      routing_table = "via-app"
      gateway       = "172.18.0.2"
      interface     = "veth-custom"
      comment       = "App container"
    }
    error_message = "The egress output must use the explicit routing table and interface."
  }
}

run "default_routing_table" {
  command = plan

  variables {
    egress = {
      name = "app"
    }
  }

  assert {
    condition     = output.egress.routing_table == "to-app" && output.egress.gateway == "172.18.0.2" && output.egress.interface == "veth-app" && output.egress.comment == "Container app"
    error_message = "The routing table must default to to-<egress name>."
  }
}

run "one_environment_entry_per_key" {
  command = plan

  variables {
    envs = {
      FIRST  = "one"
      SECOND = "two"
    }
  }

  assert {
    condition     = toset(keys(routeros_container_envs.this)) == toset(["FIRST", "SECOND"])
    error_message = "There must be one environment entry per key."
  }

  assert {
    condition     = alltrue([for key, entry in routeros_container_envs.this : entry.name == "app" && entry.key == key])
    error_message = "Each environment entry must belong to the list named after the container and carry its key."
  }

  assert {
    condition     = nonsensitive(routeros_container_envs.this["FIRST"].value == "one" && routeros_container_envs.this["SECOND"].value == "two")
    error_message = "Each environment entry must carry its value."
  }

  assert {
    condition     = routeros_container.this.envlist == "app"
    error_message = "The container must use the environment list."
  }
}

run "start_on_create" {
  command = plan

  variables {
    start_on_create       = true
    start_on_boot         = true
    auto_restart_interval = "1m"
    devices               = ["dev1"]
  }

  assert {
    condition     = routeros_container.this.running == true
    error_message = "start_on_create must start the container on creation."
  }

  assert {
    condition     = routeros_container.this.start_on_boot == true && routeros_container.this.auto_restart_interval == "1m"
    error_message = "Explicit start settings must be passed through."
  }

  assert {
    condition     = routeros_container.this.devices == toset(["dev1"])
    error_message = "Devices must be passed through."
  }
}

run "addresses_in_different_prefixes" {
  command = plan

  variables {
    network = {
      router_address    = "172.18.0.1/30"
      container_address = "172.18.0.6/30"
    }
  }

  expect_failures = [var.network]
}

run "different_prefix_lengths" {
  command = plan

  variables {
    network = {
      router_address    = "172.18.0.1/30"
      container_address = "172.18.0.2/29"
    }
  }

  expect_failures = [var.network]
}

run "equal_host_addresses" {
  command = plan

  variables {
    network = {
      router_address    = "172.18.0.1/30"
      container_address = "172.18.0.1/30"
    }
  }

  expect_failures = [var.network]
}

run "address_without_prefix_length" {
  command = plan

  variables {
    network = {
      router_address    = "172.18.0.1"
      container_address = "172.18.0.2/30"
    }
  }

  expect_failures = [var.network]
}
