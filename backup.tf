# make backup

resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "snapshot"

  schedule_policy {
    expression = "0 1 * * *"
  }

  snapshot_count = 7
  snapshot_spec {
      description = "Daily snapshot"
 }

  disk_ids = ["epdlo2nf9ifgmpov2als", 
             "fhm1c3hu92gcs8gdmtf6",
             "fhm75enmdb9cajrp7jjk",
             "fhmdumbeu8bsfs7vtj66",
             "fhmhuv1g1t8uumkkg15t",
             "fhmibial86q0uis90n20",
             "fhmkm36m6n0amu414eu9"]
}
