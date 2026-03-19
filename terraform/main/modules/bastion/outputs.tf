output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "key_name" {
  value = aws_key_pair.this.key_name
}

output "role_arn" {
  value = aws_iam_role.bastion.arn
}
