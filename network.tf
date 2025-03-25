resource "yandex_vpc_network" "network-1" {
  name = "network-1"
}

#создаем подсеть zone A
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

#создаем подсеть zone B
resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2-ru-central1-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

#создаем подсеть lan zone A
resource "yandex_vpc_subnet" "subnet-lan-a" {
  name           = "subnetlan-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = yandex_vpc_route_table.rt-1.id
}

#создаем подсеть lan zone B
resource "yandex_vpc_subnet" "subnet-lan-b" {
  name           = "subnetlan-ru-central1-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.40.0/24"]
  route_table_id = yandex_vpc_route_table.rt-1.id
}

# NAT
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "gateway"
  shared_egress_gateway {}
}

# Routing
resource "yandex_vpc_route_table" "rt-1" {
  name       = "route-table"
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
