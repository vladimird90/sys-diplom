resource "yandex_compute_snapshot_schedule" "defult" {
  name = "default"

  schedule_policy {
    expression = "0 0 * * *"
  }

  retention_period = "168h"

  snapshot_spec {
    description = "retention-snapshot"
  }

  disk_ids = [
    "${yandex_compute_disk.disk_bastion.id}",
    "${yandex_compute_disk.disk_web1.id}",
    "${yandex_compute_disk.disk_web2.id}",
    "${yandex_compute_disk.disk_zabbix.id}",
    "${yandex_compute_disk.disk_kibana.id}",
    "${yandex_compute_disk.disk_elastic.id}"
  ]
}