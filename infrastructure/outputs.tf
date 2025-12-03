output "k8s_workers_addresses" {
  value = {
    for name, instance in yandex_compute_instance.workers :
    name => {
      public_ip  = instance.network_interface.0.nat_ip_address
      private_ip = instance.network_interface.0.ip_address
    }
  }
  description = "Public and private IP addresses of K8s workers"
}

output "k8s_masters_addresses" {
  value = {
    for name, instance in yandex_compute_instance.masters :
    name => {
      public_ip  = instance.network_interface.0.nat_ip_address
      private_ip = instance.network_interface.0.ip_address
    }
  }
  description = "Public and private IP addresses of K8s masters"
}