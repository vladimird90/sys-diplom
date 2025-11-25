#создаем группы безопасности(firewall)

resource "yandex_vpc_security_group" "bastion" {
  name = "bastion-sg"
  network_id = yandex_vpc_network.sysnet.id
  ingress {
    description = "Allow 0.0.0.0/0"
    protocol = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 22
  }
  egress {
    description = "Permit ANY"
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_vpc_security_group" "public" {
  name = "public-sg"
  network_id = yandex_vpc_network.sysnet.id
  ingress {
    description = "Allow ANY"
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow ANY"
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_vpc_security_group" "LAN" {
  name = "LAN-sg"
  network_id = yandex_vpc_network.sysnet.id
  ingress {
    description = "Allow 10.0.0.0/8"
    protocol = "ANY"
    v4_cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    description = "Permit ANY"
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_vpc_security_group" "public_lb" {
  name = "public-lg"
  network_id = yandex_vpc_network.sysnet.id
  ingress {
    description = "Allow HTTP protocol"
    protocol = "TCP"
    port = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTPS protocol"
    protocol = "TCP"
    port = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Health checks from NLB"
    protocol = "TCP"
    predefined_target = "loadbalancer_healthchecks"
  }
  egress {
    description = "Permit ANY"
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"] 
  }
}