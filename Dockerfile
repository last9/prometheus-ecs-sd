# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Install cron
RUN apt-get update && apt-get -y install cron

# Set the working directory in the container to /app
WORKDIR /app

# Copy the Python script into the container at /app
COPY ecs_service_discovery.py /app/

# Install any needed packages specified in requirements.txt
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/ecs-service-discovery-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/ecs-service-discovery-cron

# Apply cron job
RUN crontab /etc/cron.d/ecs-service-discovery-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log
