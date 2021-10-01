output lab-id {
    value = "lab-${random_id.labid.hex}"
}

output "hostnames_db" {
  value = [
    for instance in vsphere_virtual_machine.couchbase_nodes:
    instance.name
  ]
}

output "hostnames_gen" {
  value = [
    for instance in vsphere_virtual_machine.generator_nodes:
    instance.name
  ]
}

output "service_list" {
  value = [
    for tag in vsphere_tag.services:
    "${tag.name}:${tag.description}"
  ]
}

output "inventory_db" {
  value = [
    for instance in vsphere_virtual_machine.couchbase_nodes:
    instance.default_ip_address
  ]
}

output "inventory_gen" {
  value = [
    for instance in vsphere_virtual_machine.generator_nodes:
    instance.default_ip_address
  ]
}

