#ВМ bastion
resource "yandex_compute_instance" "bastion" {
  name = "bastion"
  hostname = "bastion"
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    cores = var.resources.cores
    memory = var.resources.memory
    core_fraction = var.resources.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_bastion.id
  }

  metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.sysnet_public.id
    nat = true
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.bastion.id]
    ip_address = "10.0.1.3"
  }
}

#ВМ веб-сервера 1
resource "yandex_compute_instance" "web1" {
  name = "web1"
  hostname = "web1"
  platform_id = "standard-v3"
  zone = "ru-central1-b"


  resources {
    cores = var.resources.cores
    memory = var.resources.memory
    core_fraction = var.resources.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_web1.id
  }

  metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.sysnet_private_1.id
    nat = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
    ip_address = "10.0.2.3"
  }
}

#ВМ веб-сервера 2
resource "yandex_compute_instance" "web2" {
  name = "web2"
  hostname = "web2"
  platform_id = "standard-v3"
  zone = "ru-central1-d"

  resources {
    cores = var.resources.cores
    memory = var.resources.memory
    core_fraction = var.resources.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_web2.id
  }

  metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.sysnet_private_2.id
    nat = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
    ip_address = "10.0.3.3"
  }
}

#ВМ Zabbix
resource "yandex_compute_instance" "zabbix" {
  name = "zabbix"
  hostname = "zabbix"
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    cores = var.resources.cores
    memory = var.resources.memory
    core_fraction = var.resources.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_zabbix.id
  }

  metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.sysnet_public.id
    nat = true
    security_group_ids = [yandex_vpc_security_group.public.id]
    ip_address = "10.0.1.4"
  }
}

#ВМ Kibana
resource "yandex_compute_instance" "kibana" {
  name = "kibana"
  hostname = "kibana"
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    cores = var.resources.cores
    memory = var.resources.memory
    core_fraction = var.resources.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_kibana.id
  }

  metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.sysnet_public.id
    nat = true
    ip_address = "10.0.1.5"
  }
}

#ВМ ElasticSearch
resource "yandex_compute_instance" "elastic" {
  name = "elastic"
  hostname = "elastic"
  platform_id = "standard-v3"
  zone = "ru-central1-b"

  resources {
    cores = var.resources.cores
    memory = 4
    core_fraction = var.resources.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_elastic.id
  }

  metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.sysnet_private_1.id
    nat = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
    ip_address = "10.0.2.4"
  }
}

#Формирование host.ini для Ansible
resource "local_file" "inventory" {
  content  = <<-XYZ
  [all:vars]
  ansible_ssh_user=vadyakov
  ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ${var.user}@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'

  [webservers]
  ${yandex_compute_instance.web1.fqdn}
  ${yandex_compute_instance.web2.fqdn}

  [zabbix]
  ${yandex_compute_instance.zabbix.fqdn}

  [kibana]
  ${yandex_compute_instance.kibana.fqdn}
  
  [elastic]
  ${yandex_compute_instance.elastic.fqdn}
  XYZ
  filename = "./hosts.ini"
}