# ============================================
# EKS Module - Main Control Tower
# ============================================
# This module orchestrates the EKS cluster, node groups, and IAM roles
# for running 5 microservices: User-svc, Schedule-svc, Strategy-svc, 
# Insight-svc, InsightAI-svc

# Note: All resources are conditionally created based on var.create_eks_cluster
# This allows the module to be included but not create resources unless explicitly enabled
