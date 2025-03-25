#считываем данные об образе ОС
# Создание VM
resource "yandex_compute_instance" "firewall" {
  name         = "firewall"
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
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.firewall-external-security.id]
  }
  metadata = {
  user-data          = file("./cloud-init.yml")
  serial-port-enable = 1
  }
}

#firewall-external-security
resource "yandex_vpc_security_group" "firewall-external-security" {
  name        = "firewall-external-security"
  description = "Public Group firewall"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "ANY"
    description    = "Allow 22"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "All"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "local_file" "firewall" {
  content  = <<-EOF
  [firewall]
  ${yandex_compute_instance.firewall.network_interface.0.nat_ip_address} ansible_user=biparasite


  EOF
  filename = "./ansible/firewall.ini"
}