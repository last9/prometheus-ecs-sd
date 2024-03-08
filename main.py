import boto3
import json
import argparse
import os
from botocore.exceptions import ClientError, NoCredentialsError


def assume_role(arn, session_name, region):
  if not arn:
    # If no role ARN provided, return None to use default credentials
    return None
  sts_client = boto3.client('sts', region_name=region)
  try:
    assumed_role = sts_client.assume_role(RoleArn=arn, RoleSessionName=session_name)
    credentials = assumed_role['Credentials']
    return credentials
  except ClientError as e:
    print(f"Error assuming role: {e}")
    return None


def get_ecs_services(cluster_name, region, credentials=None):
  if credentials:
    ecs = boto3.client(
      'ecs',
      region_name=region,
      aws_access_key_id=credentials['AccessKeyId'],
      aws_secret_access_key=credentials['SecretAccessKey'],
      aws_session_token=credentials['SessionToken']
    )
  else:
    ecs = boto3.client('ecs', region_name=region)

  services = ecs.list_services(cluster=cluster_name)['serviceArns']
  detailed_services = ecs.describe_services(cluster=cluster_name, services=services)
  return detailed_services['services']


def get_task_ips(cluster_name, service_name, region, credentials=None):
  if credentials:
    ecs = boto3.client(
      'ecs',
      region_name=region,
      aws_access_key_id=credentials['AccessKeyId'],
      aws_secret_access_key=credentials['SecretAccessKey'],
      aws_session_token=credentials['SessionToken'],
      aws_region=credentials['Region']
    )
  else:
    ecs = boto3.client('ecs', region_name=region )

  # List tasks for the given service
  task_arns = ecs.list_tasks(cluster=cluster_name, serviceName=service_name)['taskArns']
  if not task_arns:
    return []

  # Describe tasks to get details
  tasks = ecs.describe_tasks(cluster=cluster_name, tasks=task_arns)['tasks']
  ips = []
  for task in tasks:
    for attachment in task.get('attachments', []):
      for detail in attachment.get('details', []):
        if detail['name'] == 'privateIPv4Address':
          ips.append(detail['value'])
  return ips


def main():
  parser = argparse.ArgumentParser(description='Generate Prometheus file_sd_config for AWS ECS.')
  parser.add_argument('--cluster_name', type=str, help='ECS cluster name', required=True)
  parser.add_argument('--output_dir', type=str, help='Directory to output the JSON file', required=True)
  parser.add_argument('--role_arn', type=str, default=None, help='ARN of the role to assume (optional)')
  parser.add_argument('--scrape_port', type=str, default=None, help='Port number of the Scrape service', required=True)
  parser.add_argument('--region', type=str, default=None, help='AWS Region', required=True)

  args = parser.parse_args()

  credentials = assume_role(args.role_arn, args.region, 'ecs_sd_script') if args.role_arn else None

  file_sd_config = []

  for service in get_ecs_services(args.cluster_name, args.region, credentials):
    try:
      service_name = service['serviceName']
      ips = get_task_ips(args.cluster_name, service_name, args.region, credentials)
      targets = [f"{ip}:{args.scrape_port}" for ip in ips]

      file_sd_config.append({
        "targets": targets,
        "labels": {
          "job": service_name,
          "ecs_cluster": args.cluster_name,
          "ecs_service_name": service_name
        }
      })
    except NoCredentialsError as e:
      print(f"An error occurred: {e}")
      file_sd_config.append({
        "targets": [],
        "labels": {}
      })
    finally:
      output_file = os.path.join(args.output_dir, 'ecs_file_sd_config.json')
      with open(output_file, 'w') as file:
        json.dump(file_sd_config, file, indent=4)


if __name__ == "__main__":
  main()
