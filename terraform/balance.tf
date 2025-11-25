#Target Group
resource "yandex_alb_target_group" "web_tg" {
    name = "web-target-group"

    target {
        subnet_id = yandex_vpc_subnet.sysnet_private_1.id
        ip_address = yandex_compute_instance.web1.network_interface.0.ip_address
    }

    target {
        subnet_id = yandex_vpc_subnet.sysnet_private_2.id
        ip_address = yandex_compute_instance.web2.network_interface.0.ip_address
    }
}

#Backend Group
resource "yandex_alb_backend_group" "web_bg" {
    name = "web-backend-group"

    http_backend {
        name = "http-backend"
        weight = 1
        port = 80
        target_group_ids = ["${yandex_alb_target_group.web_tg.id}"]
        load_balancing_config {
            panic_threshold = 80
        }
        healthcheck {
            timeout = "1s"
            interval = "2s"
            http_healthcheck {
                path = "/"
            }
        }
    }
}

#HTTP-роутер
resource "yandex_alb_http_router" "web_router" {
    name = "web-http-router"
}

resource "yandex_alb_virtual_host" "web_vhost" {
    name = "web-virtual-host"
    http_router_id = yandex_alb_http_router.web_router.id
    route {
        name = "web-route"
        http_route {
            http_match {
                path {
                    prefix = "/"
                }
            }
            http_route_action {
                backend_group_id = yandex_alb_backend_group.web_bg.id
                timeout = "3s"
            }
        }
    }
}

#L7 балансировщик
resource "yandex_alb_load_balancer" "web_balancer" {
    name = "web-balancer"
    network_id = yandex_vpc_network.sysnet.id
    security_group_ids = [yandex_vpc_security_group.public_lb.id]

    allocation_policy {
        location {
            zone_id = "ru-central1-b"
            subnet_id = yandex_vpc_subnet.sysnet_private_1.id
        }
    }

    listener {
        name = "web-listener"
        endpoint {
            address {
                external_ipv4_address {                    
                }
            }
            ports = [80]
        }
        http {
            handler {
                http_router_id = yandex_alb_http_router.web_router.id
            }
        }
    }
}