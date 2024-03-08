# Use an official Python runtime as a parent image
FROM python:3.11

RUN apt-get update
RUN apt-get install -y cron

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file to the working directory
COPY requirements.txt .

# Install project dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Python script and poetry files (pyproject.toml, poetry.lock) into the container at /app
COPY main.py crontab ./

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
