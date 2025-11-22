# Собираем данные для шаблона
locals {
  masters_inventory = {
    for addr in yandex_compute_instance.masters :
    addr.name => {
      public_ip = addr.network_interface[0].nat_ip_address
    }
  }

  workers_inventory = {
    for addr in yandex_compute_instance.workers :
    addr.name => {
      public_ip = addr.network_interface[0].nat_ip_address
    }
  }
}

# Генерируем inventory.yml
resource "local_file" "ansible_inventory" {
  content = templatefile(
    "${path.module}/templates/inventory.tftpl",
    {
      masters      = local.masters_inventory
      workers      = local.workers_inventory
    }
  )

  filename = "${path.root}/${var.ansible_inventory_path}"

  depends_on = [
    yandex_compute_instance.masters,
    yandex_compute_instance.workers
  ]
}