output "external_ip_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "external_ip_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "external_ip_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}