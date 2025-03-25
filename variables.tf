variable "cloud_id" {
    type=string
    default="b1gd2j85a1qkvque4sv7"
}
variable "folder_id" {
    type=string
    default="b1g58l0sc9sfdif3gs79"
}

#считываем данные об образе ОС
data "yandex_compute_image" "ubuntu_22_04_lts" {
  family = "ubuntu-2204-lts"
}
