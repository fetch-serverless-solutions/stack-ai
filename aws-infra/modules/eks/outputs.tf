output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  value = aws_security_group.cluster.id
}

output "cluster_iam_role_arn" {
  value = aws_iam_role.cluster.arn
}

output "node_security_group_id" {
  value = aws_security_group.node.id
}


