output "ecs_service_name" {
  value = aws_ecs_service.my_service.name
}

output "efs_id" {
  value = aws_efs_file_system.my_efs.id
}
