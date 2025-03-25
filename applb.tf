# Объединение виртуальных машин в Target Group
resource "yandex_alb_target_group" "tg" {
  name = "tg-1"
  target {
    subnet_id = yandex_vpc_subnet.subnet-lan-a.id
    ip_address = yandex_compute_instance.vm1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-lan-b.id
    ip_address = yandex_compute_instance.vm2.network_interface.0.ip_address
 }
}

# Создание Backend Group
resource "yandex_alb_backend_group" "bg" {
  name                     = "bg-1"
  http_backend {
    name                   = "backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.tg.id]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "tf-router" {
  name          = "tf-router-1"
  labels        = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name           = "my-virtual-host"
  http_router_id = "${yandex_alb_http_router.tf-router.id}"
  route {
    name = "my-route"
    http_route {
      http_route_action {
        backend_group_id = "${yandex_alb_backend_group.bg.id}"
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name        = "alb-1"
  network_id  = yandex_vpc_network.network-1.id
  security_group_ids = [yandex_vpc_security_group.balancer-security.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-1.id
    }
  }

  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}

resource "yandex_vpc_security_group" "balancer-security" {
  name        = "bs"
  description = "Balancer"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "ANY"
    description    = "Allow 80"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
 
   ingress {
    protocol       = "TCP"
    description    = "Health"
	predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    protocol       = "ANY"
    description    = "All"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}