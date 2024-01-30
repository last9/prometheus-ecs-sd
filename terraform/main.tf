provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "my_cluster" {
  name = var.ecs_cluster_name
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for ECS Task Role
resource "aws_iam_policy" "ecs_task_policy" {
  name        = "ecs_task_policy"
  description = "ECS Task policy to access ECS resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:List*",
          "ecs:Describe*",
          "ecs:Get*"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

resource "aws_ecs_task_definition" "last9-prom-service-discovery-task" {
  family                   = "my-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "my-container",
    image = var.docker_image,
    mountPoints = [{
      sourceVolume  = "efs-volume",
      containerPath = var.efs_mount_path
    }]
  }])

  volume {
    name = "efs-volume"

    efs_volume_configuration {
      file_system_id     = efs_file_system_id
      root_directory     = var.efs_mount_path
      transit_encryption = "ENABLED"
    }
  }
}

# IAM roles and policies
# ... (Define aws_iam_role.ecs_execution_role and aws_iam_role.ecs_task_role here)

resource "aws_ecs_service" "last9-prom-service-discovery-service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.last9-prom-service-discovery-task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.last9-prom-sd_ecs_sg.id]
    assign_public_ip = true
  }

  desired_count = 1
}

# EFS resources
# ... (Define aws_efs_file_system.my_efs and related resources here)

# Security groups
resource "aws_security_group" "last9-prom-sd_ecs_sg" {
  name        = "ecs-sg"
  description = "Security group for ECS service"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rules can be defined as needed
}
