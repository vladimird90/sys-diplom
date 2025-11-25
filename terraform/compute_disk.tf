#считываем данные об образе ОС
data "yandex_compute_image" "ubuntu_2404_lts" {
  family = "ubuntu-2404-lts"
}

resource "yandex_compute_disk" "disk_bastion" {
  name = "disk-bastion"
  type = var.disk_type
  zone = "ru-central1-a"
  size = var.disk_size
  image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
}

resource "yandex_compute_disk" "disk_web1" {
  name = "disk-web1"
  type = var.disk_type
  zone = "ru-central1-b"
  size = var.disk_size
  image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
}

resource "yandex_compute_disk" "disk_web2" {
  name = "disk-web2"
  type = var.disk_type
  zone = "ru-central1-d"
  size = var.disk_size
  image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
}

resource "yandex_compute_disk" "disk_zabbix" {
  name = "disk-zabbix"
  type = var.disk_type
  zone = "ru-central1-a"
  size = var.disk_size
  image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
}

resource "yandex_compute_disk" "disk_kibana" {
  name = "disk-kibana"
  type = var.disk_type
  zone = "ru-central1-a"
  size = var.disk_size
  image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
}

resource "yandex_compute_disk" "disk_elastic" {
  name = "disk-elastic"
  type = var.disk_type
  zone = "ru-central1-b"
  size = var.disk_size
  image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
}