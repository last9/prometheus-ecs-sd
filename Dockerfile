# Use an official Python runtime as a parent image
FROM python:3.11-slim

RUN apt-get update
RUN apt-get install -y cron

# Install Poetry
RUN pip install poetry

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

# Set the working directory in the container to /app
WORKDIR /app

# Copy the Python script and poetry files (pyproject.toml, poetry.lock) into the container at /app
COPY main.py pyproject.toml poetry.lock crontab /app/

# Install project dependencies
RUN poetry install && rm -rf $POETRY_CACHE_DIR

### Enable this if you want to run this as a one off process
## Run ecs_service_discovery.py when the container launches
#CMD ["python", "./main.py"]

COPY main.py crontab /app/

RUN poetry install

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
