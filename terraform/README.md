# Terraform Module for AWS ECS with EFS

## Overview

This Terraform module deploys a Docker container as an AWS ECS Fargate task with an attached Amazon EFS filesystem. It's designed to dynamically generate a Prometheus `file_sd_config.json` file for services running on AWS ECS.

## Prerequisites

- Terraform v0.12+ installed
- AWS CLI installed and configured
- An AWS account with appropriate permissions
- Docker image for the Python script hosted in a repository accessible by ECS

## Module Features

- **ECS Fargate Task**: Deploys a Docker container as a Fargate task in ECS.
- **EFS Filesystem**: Attaches an EFS filesystem to the ECS task for persistent storage.
- **Security Groups**: Configures security groups for ECS and EFS communication.
- **Networking**: Configures the task to run in specified subnets within a VPC.

## Input Variables

- `region`: AWS region where resources will be created.
- `ecs_cluster_name`: Name of the ECS cluster.
- `docker_image`: Docker image to use in the ECS task.
- `container_port`: Port on which the container will listen.
- `efs_mount_path`: Mount path for the EFS volume in the container.
- `subnet_ids`: List of subnet IDs for the ECS service.
- `vpc_id`: VPC ID where the ECS service and EFS will reside.
- `efs_file_system_id` = EFS ID 
- `efs_mount_path`     = EFS Mount Path

## Usage

To use this module in your Terraform environment, add the following configuration to your Terraform file:

```hcl
module "my_ecs_module" {
  source = "./path/to/my-ecs-module"

  region             = "ap-south-1"
  ecs_cluster_name   = "my-cluster"
  docker_image       = "my-docker-image:latest"
  container_port     = 80
  efs_mount_path     = "/mnt/efs"
  subnet_ids         = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]
  vpc_id             = "vpc-zzzzzzzz"
  efs_file_system_id = "fs-12345678"
  efs_mount_path     = "/mnt/efs"
}
```

Replace the values with your specific configuration.

## Outputs

- `ecs_service_name`: The name of the created ECS service.
- `efs_id`: The ID of the created EFS filesystem.

## Additional Information

- Ensure that the Docker image specified in `docker_image` is accessible by ECS and contains the necessary script or application.
- Modify the module for additional configurations such as autoscaling, IAM roles, and security group rules as needed.

---

This README provides essential information on using the Terraform module. You can extend this README to include more detailed instructions, any known limitations, or additional configuration options as required for your specific use case.
