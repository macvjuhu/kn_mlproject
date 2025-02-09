/*
output "instance_id" {
  description = "The ID of the created instance"
  value       = aws_instance.example.id
}

output "instance_public_ip" {
  description = "The public IP of the created instance"
  value       = aws_instance.example.public_ip
}
*/

output "ecr_repository_url" {
  value       = aws_ecr_repository.dev_ecr_repo.repository_url
  description = "URL of the ECR repository"
}

output "ec2_public_ip" {
  value = aws_instance.studentperf.public_ip
}