# Создание первой виртуальной машины
resource "yandex_compute_instance" "prometheus" {
  name         = "prometheus"
  folder_id    = var.folder_id
  platform_id = "standard-v1"
  zone         = "ru-central1-a"

  resources {
    memory    = 2
    cores     = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_22_04_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-lan-a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.prometheus_sg.id]
  }

  metadata = {
  user-data          = file("./cloud-init.yml")
  serial-port-enable = 1
  }
}

resource "yandex_vpc_security_group" "prometheus_sg" {
  name = "prometheus-sg"
  network_id  = yandex_vpc_network.network-1.id
  ingress {
    protocol       = "ANY"
    description    = "Allow 22"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  ingress {
    protocol       = "ANY"
    description    = "Allow 9090"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9090
  }
  egress {
    protocol       = "ANY"
    description    = "All"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "local_file" "prometheus" {
  content  = <<-EOF
  [prometheus]
  ${yandex_compute_instance.prometheus.network_interface.0.ip_address} ansible_user=biparasite


  EOF
  filename = "./ansible/prometheus.ini"
}
