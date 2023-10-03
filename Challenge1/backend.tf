data "google_compute_instance_template" "default" {
  name    = local.instance_template
  project = var.project_id
}


locals {
  create_instance_template = var.existing_instance_template == null ? true : false
  instance_template        = local.create_instance_template ? module.nginx_vms.template.self_link : var.existing_instance_template
  nginx_tier1_subnetwork_key    = "${var.subnet_region}/${var.subnet_region}-${var.environment}-tier1-nginx"
}

module "nginx-mig" {
  source      = "github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-mig?ref=v7.0.0"
  project_id  = var.project_id
  location    = var.zone
  name        = "mig-nginx"
  target_size = var.number-of-vm
  default_version = {
    instance_template = module.nginx_vms.template.self_link
    name              = "default"
  }
  #target_pools      = [module.lb-ilb.target_pool]
  named_ports = {
  "tcp" = 10022
  }
}

locals {
  metadata = {
    startup-script = templatefile("${path.module}/scripts/nginx.sh.tpl", {
      squid_lb_ip           = var.sqpr_lb_ip_address,
      project               = var.project_id,
      http_proxy            = "http://${var.sqpr_lb_ip_address}:80",
      https_proxy           = "http://${var.sqpr_lb_ip_address}:443",
      no_proxy              = "127.0.0.1,localhost,169.254.169.254,metadata,metadata.google.internal,.internal,.googleapis.com",
    })
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
  }
  instance_zone_list              = flatten([for zone in var.zones : [for i in range(0, var.instances_per_zone) : zone]])
  instance_id_lists_by_zone_index = chunklist(module.nginx_vms.self_links, var.instances_per_zone)

  }
  
module "nginx_vms" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-vm?ref=v4.4.2"
  project_id = var.project_id
  name       = var.vm_name
  region     = var.region
  zones      = local.instance_zone_list
  service_account_create = true
  network_interfaces = [{
    network    = module.gke_vpc.network_self_link
    subnetwork = "projects/${var.project_id}/regions/${var.subnet_region}/subnetworks/${var.nginx_subnet_name_tier1 }"
    nat        = false
    addresses  = null
    alias_ips  = null
  }]
  use_instance_template = true
  instance_count = var.instances_per_zone * length(var.zones)
  tags           = distinct(concat(var.other_vm_network_tags, [var.lb_network_tag]))
  metadata       = local.metadata
  labels         = merge(var.labels, { tier = "web" })
  boot_disk = {
    image        = "projects/pid-gousgggp-ssvc-os-images/global/images/nginx-rhel-8-v202204180930-golden"
    type         = "pd-ssd"
    size         = 500
  }
  encryption  = {
   encrypt_boot            = true
   kms_key_self_link       = "projects/${var.project_id}/locations/${var.key_region}/keyRings/${var.key_ring_name}/cryptoKeys/${var.keys}-${var.environment}-02"

   disk_encryption_key_raw = null
 }

instance_type = var.instance_type

}

resource "random_id" "group" {
  count       = length(var.zones)
  byte_length = 2
}
