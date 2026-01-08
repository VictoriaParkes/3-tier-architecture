# Define values that Terraform shoukd display after creating infrastructure
# that yourself or other systems might need to use.

# Kubernetes API server URL
output "cluster-endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

# Security group protecting the control plane
output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

# AWS region where resources are deployed
output "region" {
  description = "AWS region"
  value       = var.region
}

# Name of EKS cluster
output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

# Jenkins-related outputs
output "jenkins_role_arn" {
  description = "ARN of the Jenkins IAM role"
  value       = aws_iam_role.jenkins_role.arn
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "ecr_repository_url" {
  description = "ECR repository URL for Jenkins to push images"
  value       = aws_ecr_repository.ecr.repository_url
}
