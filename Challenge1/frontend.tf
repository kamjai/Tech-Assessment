resource "google_compute_address" "nlb_address" {
  name             = "nlb-static-address"
  project          = var.project_id
  region           = var.region
  address_type     = "EXTERNAL"
  
}

# forwarding rule
resource "google_compute_forwarding_rule" "nlb-fw-rule" {
  project               = var.project_id
  region                = var.region
  name                  = "nlb-forwarding-rule"
  provider              = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "10022"
  ip_address            = google_compute_address.nlb_address.id
  backend_service       = google_compute_region_backend_service.nlb-backend-service.id
  labels     = var.asset_label
  depends_on = [google_compute_address.nlb_address]
}

# backend service
resource "google_compute_region_backend_service" "nlb-backend-service" {
  project = var.project_id
  name                  = "nlb-proxy-xlb-backend-service"
  provider              = google-beta
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_region_health_check.nlb-hc.id]
  backend {
    group           = module.nginx-mig.group_manager.instance_group
    balancing_mode  = "CONNECTION"
  }
}

#health-check
resource "google_compute_region_health_check" "nlb-hc" {
  project          = var.project_id
  provider           = google-beta
  name               = "nlb-health-check"
  check_interval_sec = 1
  timeout_sec        = 1
  region             = var.region

  tcp_health_check {
    port = "10022"
  }
}
