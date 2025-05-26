terraform {
  required_version = ">= 1.11.0"
  backend "gcs" {
    bucket  = "tosuke-homelab-tfstate"
    prefix  = "linode"
  }

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.38.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}

provider "linode" {
  api_version = "v4beta"
}

data "linode_sshkeys" "ssh_keys" {}

data "linode_region" "region" {
  id = "jp-tyo-3"
}

locals {
  border_primary     = "border-0"
  border_secondaries = toset(["border-1"])
  border_nodes = setunion(
    [local.border_primary],
    local.border_secondaries,
  )

  border_addresses = {
    for key in local.border_nodes :
    key => setunion(
      flatten([
        for key in setsubtract(local.border_nodes, [key]) :
        linode_instance.border[key].ipv4
      ]),
      [linode_ipv6_range.border_ipv6.range]
    )
  }
}

resource "linode_instance" "border" {
  for_each = local.border_nodes

  label = each.key
  tags  = ["border"]

  region = data.linode_region.region.id
  type   = "g6-nanode-1"

  metadata {
    user_data = base64encode(templatefile("nix-infect-cloud-init.yaml", {
      fqdn         = "linode-${each.key}.nodes.tosuke.dev"
      hostname     = "linode-${each.key}"
      resolvers    = jsonencode(flatten([for resolver in data.linode_region.region.resolvers : split(",", resolver.ipv6)]))
      nixos_infect = base64gzip(data.http.nixos_infect.response_body)
    }))
  }
}

data "http" "nixos_infect" {
  url = "https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect"
}

resource "linode_instance_config" "border" {
  for_each  = local.border_nodes
  linode_id = linode_instance.border[each.key].id
  label     = "border config"
  booted    = true

  kernel = "linode/latest-64bit"

  helpers {
    network = false
  }

  device {
    device_name = "sda"
    disk_id     = linode_instance_disk.border_boot[each.key].id
  }
  device {
    device_name = "sdb"
    disk_id     = linode_instance_disk.border_swap[each.key].id
  }

  interface {
    purpose = "public"
  }
  interface {
    purpose = "vlan"
    label   = "private"
  }
}

resource "linode_instance_disk" "border_boot" {
  for_each        = local.border_nodes
  linode_id       = linode_instance.border[each.key].id
  label           = "boot"
  size            = linode_instance.border[each.key].specs[0].disk - 512
  image           = "linode/ubuntu24.04"
  authorized_keys = [for key in data.linode_sshkeys.ssh_keys.sshkeys : key.ssh_key]
}

resource "linode_instance_disk" "border_swap" {
  for_each   = local.border_nodes
  linode_id  = linode_instance.border[each.key].id
  label      = "swap"
  size       = 512
  filesystem = "swap"
}

resource "linode_ipv6_range" "border_ipv6" {
  linode_id     = linode_instance.border[local.border_primary].id
  prefix_length = 56
}

resource "linode_instance_shared_ips" "border_shared_primary" {
  linode_id = linode_instance.border[local.border_primary].id
  addresses = local.border_addresses[local.border_primary]
}

resource "linode_instance_shared_ips" "border_shared_secondaries" {
  for_each   = local.border_secondaries
  depends_on = [linode_instance_shared_ips.border_shared_primary]

  linode_id = linode_instance.border[each.key].id
  addresses = local.border_addresses[each.key]
}

