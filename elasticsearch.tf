# Создание первой виртуальной машины
resource "yandex_compute_instance" "elasticsearch" {
  name         = "elasticsearch"
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
    security_group_ids = [yandex_vpc_security_group.elasticsearch_sg.id]
  }

  metadata = {
  user-data          = file("./cloud-init.yml")
  serial-port-enable = 1
  }
}

resource "yandex_vpc_security_group" "elasticsearch_sg" {
  name = "elasticsearch-sg"
  network_id  = yandex_vpc_network.network-1.id
  ingress {
    protocol       = "ANY"
    description    = "Allow 22"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }  
  ingress {
    protocol       = "ANY"
    description    = "Allow 9200"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9200
  }
  egress {
    protocol       = "ANY"
    description    = "All"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "local_file" "elasticsearch" {
  content  = <<-EOF
  [elasticsearch]
  ${yandex_compute_instance.elasticsearch.network_interface.0.ip_address} ansible_user=biparasite


  EOF
  filename = "./ansible/elasticsearch.ini"
}
