output "fqdn" {
  value       = local.fqdn
  description = "The fully qualified domain name."
}

output "downstream_state_bucket" {
  value       = var.downstream_state_bucket
  description = "The S3 Bucket where custom state files are saved."
}

output "known_hosts_object" {
  value       = local.known_hosts_object
  description = "The S3 path of the known_hosts file."
}
