output "db-node-ips" {
  value = [
    for instance in aws_instance.couchbase_nodes:
    instance.public_ip
  ]
}

output "gen-node-ips" {
  value = [
    for instance in aws_instance.generator_nodes:
    instance.public_ip
  ]
}

output "db-node-names" {
  value = [
    for instance in aws_instance.couchbase_nodes:
    lookup(instance.tags, "Name")
  ]
}

output "gen-node-names" {
  value = [
    for instance in aws_instance.generator_nodes:
    lookup(instance.tags, "Name")
  ]
}

output "load-balancer-name" {
  value = aws_lb.load_balancer.dns_name
}
