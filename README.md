# AWS ECS Service Discovery Script

## Overview

This Python script dynamically generates a Prometheus `file_sd_config.json` file for services running on AWS ECS, extracting task IP addresses for Prometheus monitoring. The script now also allows specifying an output directory for the generated JSON file.

## Prerequisites

- Python 3.x
- Boto3 library
- AWS CLI (optional, for AWS configurations)
- AWS account with appropriate permissions
- ECS cluster with running services

## Installation

1. **Clone the Repository**:

   ```sh
   git clone https://your-repository-url.git
   cd your-repository-directory
   ```

2. **Install Dependencies**:

   Install the required Python packages using:

   ```sh
   pip install boto3
   ```

3. **AWS Configuration**:

   Ensure your AWS credentials are configured. This can be done by setting up the AWS CLI or by exporting your credentials as environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN`).

## Usage

Run the script with the following parameters:

```sh
python ecs_service_discovery.py <cluster_name> [--role_arn <role_arn>] --output_dir <output_directory>
```

- `<cluster_name>`: Name of the ECS cluster.
- `[--role_arn <role_arn>]`: (Optional) The ARN of the IAM role to assume. If not provided, the script will use default credentials.
- `<output_directory>`: The directory where the `ecs_file_sd_config.json` file will be saved.

### Example

```sh
python ecs_service_discovery.py my-cluster --role_arn arn:aws:iam::123456789012:role/myRole --output_dir /path/to/output --scrape_port 9097
```

## Docker Container

This script can also be run as a Docker container, which will execute the script every 3 minutes.

### Building the Docker Image

1. Build the Docker image using:

   ```bash
   docker build -t ecs-service-discovery .
   ```

2. Run the Docker container:

   ```bash
   docker run -e AWS_ACCESS_KEY_ID=your_access_key -e AWS_SECRET_ACCESS_KEY=your_secret_key -e AWS_DEFAULT_REGION=your_region -v /path/to/output:/app/output ecs-service-discovery my-cluster --role_arn arn:aws:iam::123456789012:role/myRole --output_dir /path/to/output --scrape_port 9097
   ```

   Ensure to replace the AWS credentials and region with your own. The `-v` flag mounts the output directory from your host to the container.

### Dockerfile

The `Dockerfile` is set up to install the necessary dependencies, set up a cron job to run the script every 3 minutes, and log the output.

## Output

The script outputs a file named `ecs_file_sd_config.json` in the specified output directory. This file contains the Prometheus scrape configuration for the discovered ECS services.

## Note

The script is designed for dynamic service discovery in AWS ECS environments. Ensure that the AWS credentials provided have the necessary permissions to access ECS services.

---

This `README.md` provides comprehensive information on using your Python script and the Docker container. Feel free to modify it to include additional details like troubleshooting tips, contribution guidelines, licensing, or support information as needed.
