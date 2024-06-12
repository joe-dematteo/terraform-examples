# ECS Rolling Deployment

## Overview

This is a template/example for how to deploy a rolling deployment of an ECS service using Terraform.

This example utilizes aws terraform modules to create the following resources:
- VPC
- Subnets
- Security Groups
- ECS Cluster
- ECS Service
- ECS Task Definition (Initial Task Definition)
- ALB
- Autoscaling Group