variable "region" {
  description = "AWS Region"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "docker_image" {
  description = "Docker image to use in the ECS task"
  type        = string
}

variable "efs_mount_path" {
  description = "Mount path for the EFS volume in the container"
  type        = string
  default = "/efs/mnt"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the ECS service and EFS will reside"
  type        = string
}

variable "efs_file_system_id" {
  description = "The ID of the existing EFS file system"
  type        = string
}
