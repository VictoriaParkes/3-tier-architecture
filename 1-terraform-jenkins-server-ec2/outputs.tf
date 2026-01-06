# # Output in the terminal the address of the Jenkins server, once it's created
# output "ec2_public_ip" {
#   value = aws_instance.jenkins-server.public_ip
# }


# outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = aws_instance.jenkins.id
}

output "jenkins_private_ip" {
  description = "Private IP of Jenkins instance"
  value       = aws_instance.jenkins.private_ip
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = var.use_cognito_auth ? aws_cognito_user_pool.main[0].id : null
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = var.use_cognito_auth ? aws_cognito_user_pool.main[0].arn : null
}

output "cognito_client_id" {
  description = "Cognito User Pool Client ID"
  value       = var.use_cognito_auth ? aws_cognito_user_pool_client.main[0].id : null
  sensitive   = true
}

output "cognito_domain" {
  description = "Cognito User Pool Domain"
  value       = var.use_cognito_auth ? aws_cognito_user_pool_domain.main[0].domain : null
}

output "access_url" {
  description = "URL to access Jenkins (use custom domain if configured)"
  value       = "https://${aws_lb.main.dns_name}"
}

output "ssm_command_to_get_jenkins_password" {
  description = "AWS CLI command to retrieve Jenkins initial admin password"
  value       = "aws ssm start-session --target ${aws_instance.jenkins.id} --document-name AWS-StartInteractiveCommand --parameters command='sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}
