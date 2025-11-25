#создаем облачную сеть
resource "yandex_vpc_network" "sysnet" {
  name = "sysnet"
}

#создаем публичную сеть
resource "yandex_vpc_subnet" "sysnet_public" {
  name = "sysnet-ru-central1-a"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.sysnet.id
  v4_cidr_blocks = ["10.0.1.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

#создаем приватную подсеть 1
resource "yandex_vpc_subnet" "sysnet_private_1" {
  name           = "sysnet-ru-central1-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.sysnet.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

#создаем приватную подсеть 2
resource "yandex_vpc_subnet" "sysnet_private_2" {
  name           = "sysnet-ru-central1-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.sysnet.id
  v4_cidr_blocks = ["10.0.3.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

#создаем NAT для выхода в интернет
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "sysnet-gateway"
  shared_egress_gateway {}
}

#создаем сетевой маршрут для выхода в интернет через NAT
resource "yandex_vpc_route_table" "rt" {
  name       = "sysnet-route-table"
  network_id = yandex_vpc_network.sysnet.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}