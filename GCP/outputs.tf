output "public_ip" {
  value = google_compute_address.static_ip.address
}


output "ssh_private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}
