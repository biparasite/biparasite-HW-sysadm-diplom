# Создание первой виртуальной машины
resource "yandex_compute_instance" "vm1" {
  name         = "vm1"
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
    subnet_id = yandex_vpc_subnet.subnet-lan-a.id #зона ВМ должна совпадать с зоной subnet!!!
    nat       = false
  }
  metadata = {
  user-data          = file("./cloud-init.yml")
  serial-port-enable = 1
  }
}

# Создание второй виртуальной машины в другой зоне
resource "yandex_compute_instance" "vm2" {
  name         = "vm2"
  folder_id    = var.folder_id
  platform_id = "standard-v1"
  zone         = "ru-central1-b"

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
    subnet_id = yandex_vpc_subnet.subnet-lan-b.id #зона ВМ должна совпадать с зоной subnet!!!
    nat       = false
  }

  metadata = {
  user-data          = file("./cloud-init.yml")
  serial-port-enable = 1
  }
}

resource "local_file" "web" {
  content  = <<-EOF
  [web]
  ${yandex_compute_instance.vm1.network_interface.0.ip_address} ansible_user=biparasite
  ${yandex_compute_instance.vm2.network_interface.0.ip_address} ansible_user=biparasite

  EOF
  filename = "./ansible/web.ini"
}
