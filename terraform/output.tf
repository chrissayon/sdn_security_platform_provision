/*
output "output_key" {
    value = tls_private_key.key.private_key_pem
}
*/

output "web_ip" {
    value = aws_instance.web_instance.public_ip
}

output "app_ip" {
    value = aws_instance.app_instance.public_ip
}