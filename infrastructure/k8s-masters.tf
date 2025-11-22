resource "yandex_compute_instance" "masters" {
  for_each = {
    for idx, vm in var.k8s_vm_master : idx => vm
  }

  name        = "${each.value.name}-${each.key + 1}"
  hostname    = "${each.value.name}-${each.key + 1}"
  platform_id = each.value.platform_id
  zone        = each.value.zone

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = each.value.hdd_size
      type     = each.value.hdd_type
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s_subnets[each.key].id
    nat       = each.value.nat_ip
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "${var.ssh_username}:${var.ssh_pub_key}"
  }
}