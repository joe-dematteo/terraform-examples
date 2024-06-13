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

#### notes
When choosing between differenct launch types (EC2 or Fargate), and you want base your decision off of cost, consider reading [this](https://aws.amazon.com/blogs/containers/theoretical-cost-optimization-by-amazon-ecs-launch-type-fargate-vs-ec2/).

Fargate tends to be more cost-optimized when your containers are running at a lower utilization rate. However, if you have a high utilization rate, EC2 might be more cost-effective.